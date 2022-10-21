# Copyright (c) 2022, Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  alarm_mql_map = zipmap(
    ["CPU Load ScaleOut", "CPU Load ScaleIn",
      "Used Heap Percent ScaleOut", "Used Heap Percent ScaleIn",
      "Stuck Threads ScaleOut", "Stuck Threads ScaleIn",
    "Queue Length ScaleOut", "Queue Length ScaleIn"],
    [format("ProcessCpuLoad[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() > %s", var.metric_interval, var.service_prefix_name, var.max_threshold_percent / 100),
      format("ProcessCpuLoad[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() < %s", var.metric_interval, var.service_prefix_name, var.min_threshold_percent / 100),
      #e.g. if maximum threshold for used heap percent is 75, then SCALE OUT will be triggered if WLS free heap percent metrics of value is less than 25
      format("WeblogicJVMHeapFreePercent[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() < %s", var.metric_interval, var.service_prefix_name, (100 - var.max_threshold_percent)),
      #e.g. if minimum threshold for used heap percent is 40, then SCALE IN will happen if WLS free heap percent metrics of value is greater than 60
      format("WeblogicJVMHeapFreePercent[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() > %s", var.metric_interval, var.service_prefix_name, (100 - var.min_threshold_percent)),
      format("WeblogicThreadPoolStuckCount[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() > %s", var.metric_interval, var.service_prefix_name, var.max_threshold_counter),
      format("WeblogicThreadPoolStuckCount[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() < %s", var.metric_interval, var.service_prefix_name, var.min_threshold_counter),
      format("WeblogicThreadPoolQueueLength[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() > %s", var.metric_interval, var.service_prefix_name, var.max_threshold_counter),
  format("WeblogicThreadPoolQueueLength[%s]{AppserverClusterName=\"%s_cluster\"}.grouping().mean() < %s", var.metric_interval, var.service_prefix_name, var.min_threshold_counter)])

  function_config_map = zipmap(
    ["min_wls_node_count", "wlsc_email_notification_topic_id", "debug", "offline_ms1_from_lb"],
    [var.wls_node_count,
      (var.subscription_endpoint != "" ? element(concat(oci_ons_notification_topic.wlsc_email_notification_topic.*.id, list("")), 0) : ""),
      "false",
      "false"
  ])

  alarm_body = zipmap(
    ["CPU Load ScaleOut", "CPU Load ScaleIn",
      "Used Heap Percent ScaleOut", "Used Heap Percent ScaleIn",
      "Stuck Threads ScaleOut", "Stuck Threads ScaleIn",
    "Queue Length ScaleOut", "Queue Length ScaleIn"],
    ["Alert for high CPU usage",
      "Alert for low CPU usage",
      "Alert for high heap usage",
      "Alert for low heap usage",
      "Alert for high stuck thread count in thread pool",
      "Alert for low stuck thread count in thread pool",
      "Alert for high pending requests in priority queue",
  "Alert for low pending requests in priority queue"])

}
