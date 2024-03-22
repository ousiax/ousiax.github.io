---
layout: post
title: 6 - Kubernetes Monitoring
date: 2020-02-10 11:11:26 +0800
categories: ['kubernetes']
tags: ['kubernetes']
---

- TOC
{:toc}

- - -

### Prometheus Architecture

![Prometheus Architecture](https://prometheus.io/assets/architecture.png)

### Data Model (TSDB)

- A time series is a series of data points indexed (or listed or graphed) in time order. Most commonly, a time series is a sequence taken at successive equally spaced points in time. Thus it is a sequence of discrete-time data.
- Prometheus fundamentally stores all data as time series: streams of timestamped values belonging to the same metric and the same set of labeled dimensions.
- Every time series is uniquely identified by its **metric** name and optional key-value pairs called **labels**.

### Metric Names and Labels

- The metric name specifies the general feature of a system that is measured (e.g. http\_requests\_total - the total number of HTTP requests received). 
- Labels enable Prometheus's dimensional data model: any given combination of labels for the same metric name identifies a particular dimensional instantiation of that metric (for example: all HTTP requests that used the method POST to the /api/tracks handler). 
- The query language allows filtering and aggregation based on these dimensions. 
- Changing any label value, including adding or removing a label, will create a new time series.

### Notation: Time Series

- Given a metric name and a set of labels, time series are frequently identified using this notation:

    `<metric name>{<label name>=<label value>, ...}`

- For example, a time series with the metric name api\_http\_requests\_total and the labels method="POST" and handler="/messages" could be written like this:

    `api_http_requests_total{method="POST", handler="/messages"}`

### Querying Prometheus: PromQL

- Prometheus provides a functional query language called **PromQL** (Prometheus Query Language) that lets the user select and aggregate time series data in real time.
- The result of an expression can either be shown as a graph, viewed as tabular data in Prometheus's expression browser, or consumed by external systems via the HTTP API.

### Configuration

- Prometheus is configured via command-line flags and a configuration file. While the command-line flags configure immutable system parameters (such as storage locations, amount of data to keep on disk and in memory, etc.), 
- the configuration file defines everything related to scraping jobs and their instances, as well as which rule files to load.
- [https://prometheus.io/docs/prometheus/latest/configuration/configuration/](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)

### prometheus.yml

```yml
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.

scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ['localhost:9090']
```

### Exporters and Integrations

- There are a number of libraries and servers which help in exporting existing metrics from third-party systems as Prometheus metrics.
- This is useful for cases where it is not feasible to instrument a given system with Prometheus metrics directly (for example, HAProxy or Linux system stats).

- [https://prometheus.io/docs/instrumenting/exporters/](https://prometheus.io/docs/instrumenting/exporters/)
- [https://github.com/prometheus/node\_exporter](https://github.com/prometheus/node_exporter)

- [https://github.com/prometheus-net/prometheus-net](https://github.com/prometheus-net/prometheus-net)

### Kubernetes Monitoring Architecture

- System metrics (core metrics & non-metrics)

    System metrics are generic metrics that are generally available from every entity that is monitored (e.g. usage of CPU and memory by container and node).

- Service metrics

    Service metrics are explicitly defined in application code and exported (e.g. number of 500s served by the API server).
- Core (system) metrics

    which are metrics that Kubernetes understands and uses for operation of its internal components and core utilities -- for example, metrics used for scheduling (including the inputs to the algorithms for resource estimation, initial resources/vertical autoscaling, cluster autoscaling, and horizontal pod autoscaling excluding custom metrics), the kube dashboard, and “kubectl top.”

- [https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/monitoring\_architecture.md](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/monitoring_architecture.md)

### Visualization

- Expression browser
- **Grafana**

### The USE and RED Methods

- **USE**: Utilization, saturation, and errors

- **RED**: Requests, Errors, and Duration

- https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-b190cc97f0f6

- http://www.brendangregg.com/usemethod.html

### References

- [https://en.wikipedia.org/wiki/Time\_series](https://en.wikipedia.org/wiki/Time_series)
- [https://prometheus.io/docs/concepts/data\_model/](https://prometheus.io/docs/concepts/data_model/)
- [https://prometheus.io/docs/prometheus/latest/querying/basics/](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [https://prometheus.io/docs/prometheus/latest/querying/operators/](https://prometheus.io/docs/prometheus/latest/querying/operators/)
- [https://prometheus.io/docs/prometheus/latest/querying/functions/](https://prometheus.io/docs/prometheus/latest/querying/functions/)
- [https://prometheus.io/docs/prometheus/latest/configuration/configuration/](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
- [https://prometheus.io/docs/instrumenting/exporters/](https://prometheus.io/docs/instrumenting/exporters/)
- [https://github.com/prometheus/node\_exporter](https://github.com/prometheus/node_exporter)
- [https://github.com/prometheus-net/prometheus-net](https://github.com/prometheus-net/prometheus-net)
- [https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/instrumentation/monitoring_architecture.md)
- [https://github.com/kubernetes/kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
- [https://github.com/kubernetes-sigs/metrics-server/](https://github.com/kubernetes-sigs/metrics-server/)
- [https://grafana.com/docs/grafana/latest/](https://grafana.com/docs/grafana/latest/)
- [https://grafana.com/docs/grafana/latest/guides/glossary/](https://grafana.com/docs/grafana/latest/guides/glossary/)
- [https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-b190cc97f0f6](https://blog.freshtracks.io/a-deep-dive-into-kubernetes-metrics-b190cc97f0f6)
- [http://www.brendangregg.com/usemethod.html](http://www.brendangregg.com/usemethod.html)
