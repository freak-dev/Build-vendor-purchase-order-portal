package com.vendorportal;
import java.util.List;
import java.util.Map;
final class OrderWorkflow {
  private static final Map<String,List<String>> ALLOWED=Map.of("PENDING",List.of("APPROVED","CANCELLED"),"APPROVED",List.of("ORDERED","CANCELLED"),"ORDERED",List.of("RECEIVED","CANCELLED"));
  private OrderWorkflow() {}
  static boolean canTransition(String current,String next){return ALLOWED.getOrDefault(current,List.of()).contains(next);}
}
