import 'package:segment_analytics/analytics.dart';
import 'package:segment_analytics/event.dart';
import 'package:segment_analytics/plugin.dart';
import 'package:segment_analytics/plugins/destination_metadata_enrichment.dart';
import 'package:segment_analytics/plugins/queue_flushing_plugin.dart';
import 'package:segment_analytics/logger.dart';
import 'package:segment_analytics/utils/chunk.dart';

const maxEventsPerBatch = 100;
const maxPayloadSizeInKb = 500;
const segmentDestinationKey = 'Segment.io';

class SegmentDestination extends DestinationPlugin with Flushable {
  late final QueueFlushingPlugin _queuePlugin;
  String? _apiHost;

  SegmentDestination() : super(segmentDestinationKey) {
    _queuePlugin = QueueFlushingPlugin(sendEvents);
  }

  Future sendEvents(List<RawEvent> events) async {
    if (events.isEmpty) {
      return;
    }

    final List<List<RawEvent>> chunkedEvents = chunk(events,
        analytics?.state.configuration.state.maxBatchSize ?? maxEventsPerBatch,
        maxKB: maxPayloadSizeInKb);

    final List<RawEvent> sentEvents = [];
    var numFailedEvents = 0;

    // Iterate over each batch in chunkedEvents sequentially
    await Future.forEach(chunkedEvents, (batch) async {
      try {
        final succeeded = await analytics?.httpClient.startBatchUpload(
            analytics!.state.configuration.state.writeKey, batch,
            host: _apiHost);
        if (succeeded == true) { // If the upload succeeded, all events in the batch are added to sentEvents.
          sentEvents.addAll(batch);
        } else { // If it failed, increase the numFailedEvents counter by the number of events in the failed batch.
          numFailedEvents += batch.length;
        }
      } catch (e) {
        numFailedEvents += batch.length;
      }
    });

    if (sentEvents.isNotEmpty) {
      _queuePlugin.dequeue(sentEvents); // Removed events that were successfully sent from the internal queue
      log("Successfully Sent ${sentEvents.length} events", kind: LogFilterKind.debug);
    }

    if (numFailedEvents > 0) {
      log("Failed to send $numFailedEvents events", kind: LogFilterKind.error);
    }

    return;
  }

  @override
  configure(Analytics analytics) {
    super.configure(analytics);

    // Enrich events with the Destination metadata
    add(DestinationMetadataEnrichment(segmentDestinationKey));
    add(_queuePlugin);
  }

  @override
  void update(Map<String, dynamic> settings, ContextUpdateType type) {
    super.update(settings, type);
    _apiHost = settings[segmentDestinationKey]?['apiHost'];
  }

  @override
  flush() {
    return _queuePlugin.flush();
  }
}
