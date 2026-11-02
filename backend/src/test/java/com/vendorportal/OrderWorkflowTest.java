package com.vendorportal;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;
class OrderWorkflowTest {
 @Test void allowsForwardSteps(){assertTrue(OrderWorkflow.canTransition("PENDING","APPROVED"));assertTrue(OrderWorkflow.canTransition("APPROVED","ORDERED"));assertTrue(OrderWorkflow.canTransition("ORDERED","RECEIVED"));}
 @Test void allowsCancellationBeforeReceipt(){assertTrue(OrderWorkflow.canTransition("PENDING","CANCELLED"));assertTrue(OrderWorkflow.canTransition("APPROVED","CANCELLED"));assertTrue(OrderWorkflow.canTransition("ORDERED","CANCELLED"));}
 @Test void rejectsSkippedRepeatedAndTerminalTransitions(){assertFalse(OrderWorkflow.canTransition("PENDING","ORDERED"));assertFalse(OrderWorkflow.canTransition("APPROVED","RECEIVED"));assertFalse(OrderWorkflow.canTransition("RECEIVED","RECEIVED"));assertFalse(OrderWorkflow.canTransition("RECEIVED","CANCELLED"));assertFalse(OrderWorkflow.canTransition("CANCELLED","PENDING"));}
}
