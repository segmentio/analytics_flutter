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

  /// Splits a list of raw events into size-limited batches.
  /// Sends them to the Segment API one by one.
  /// Tracks which batches succeed or fail.
  /// Only dequeues (removes) events that were successfully sent.
  /// Logs everything for monitoring and debugging.
  Future sendEvents(List<RawEvent> events) async {

    // If the events list is empty, the function exits early without doing anything.
    if (events.isEmpty) {
      return;
    }

    // Break the list of events into smaller batches using the chunk() utility.
    final List<List<RawEvent>> chunkedEvents = chunk(events,
        analytics?.state.configuration.state.maxBatchSize ?? maxEventsPerBatch,
        maxKB: maxPayloadSizeInKb);

    final List<RawEvent> sentEvents = []; // a list to collect events that were successfully sent.
    var numFailedEvents = 0; // a counter to keep track of how many events failed to send.

    // Iterate over each batch in chunkedEvents sequentially using await
    await Future.forEach(chunkedEvents, (batch) async {
      try {
        // Send the current batch to the server.
        final succeeded = await analytics?.httpClient.startBatchUpload(
            analytics!.state.configuration.state.writeKey, batch,
            host: _apiHost);
        // succeeded is true if the server confirms the batch was accepted.
        if (succeeded == true) {
          sentEvents.addAll(batch); // If the upload succeeded, all events in the batch are added to sentEvents.
        } else {
          numFailedEvents += batch.length; // If failed, increase the numFailedEvents counter by the number of events in the failed batch.
        }
      } catch (e) {
        numFailedEvents += batch.length;
      }
    });

    // After all batches have been processed
    if (sentEvents.isNotEmpty) {
      // Remove successfully sent events from the queue and log them
      _queuePlugin.dequeue(sentEvents);
      log("Successfully Sent ${sentEvents.length} events.", kind: LogFilterKind.debug);
    }

    if (numFailedEvents > 0) {
      // If any events failed to send, log an error message indicating how many.
      log("Failed to send $numFailedEvents events.", kind: LogFilterKind.error);
    }

    return; // No value is returned, but it signals that async processing is complete.
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
