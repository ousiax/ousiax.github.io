---
layout: post
title: Docker Logging via EFK Stack with Docker Compose
date: 2018-06-29 15:42:23 +0800
categories: ['EFK']
tags: ['EFK', 'CNCF', 'Docker']
disqus_identifier: 17531140728367429958872257764126983915
---

- TOC
{:toc}

- - -

### What is the ELK Stack ?

"E**L**K" is the arconym for three open source projects: Elasticsearch, Logstash, and Kibana. Elasticsearch is a search and analytics engine. Logstash is a server-side data processing pipeline that ingests data from multiple sources simultaneously, tranforms it, and then sends it to a "stash" like Elasticsearch. Kibana lets users visualize data with charts and graphs in Elasticsearch.

<style>
  img {
    max-width: 65%;
  }
</style>

![ELK Stack](https://www.elastic.co/static/images/elk/elk-stack-elkb-diagram.svg)

### What is the EFK Stack ?

"E**F**K" is the arconym for Elasticsearch, Fluentd, Kibana.

![Fluentd vs. LogStash](https://www.loomsystems.com/hs-fs/hubfs/Loomsystems-July2017-Theme/Images/06c82a_e618ffd13a01435da253239f1f0e2894-mv2.jpg?t=1530217296132&width=554&name=06c82a_e618ffd13a01435da253239f1f0e2894-mv2.jpg)

> Fluentd vs. LogStash: A Feature Comparison, [https://www.loomsystems.com/blog/single-post/2017/01/30/a-comparison-of-fluentd-vs-logstash-log-collector](https://www.loomsystems.com/blog/single-post/2017/01/30/a-comparison-of-fluentd-vs-logstash-log-collector)

> Fluentd vs. Logstash: A Comparison of Log Collectors, [https://logz.io/blog/fluentd-logstash/](https://logz.io/blog/fluentd-logstash/)

#### What is the Fluentd?

- **Before Fluentd**

    ![Before Fluentd](https://www.fluentd.org/images/fluentd-before.png)

- **After Fluentd**

    ![After Fluentd](https://gblobscdn.gitbook.com/assets%2F-LR7OsqPORtP86IQxs6E%2F-LWNPJuIG9Ym5ELlFCti%2F-LWNPOPNQ1l9hvoJ2FIp%2Ffluentd-architecture.png?alt=media)

### Collect Docker logs to EFK Stack with Docker Compose.

***Talk is cheap, show me the code @ [https://github.com/qqbuby/efk-docker](https://github.com/qqbuby/efk-docker).***



```sh
$ tree
.
├── docker-compose.yml
├── env
├── fluentd
│   └── etc
│       └── fluent.conf
├── LICENSE
├── nginx
│   ├── conf.d
│   │   ├── default.conf
│   │   ├── gzip.mime.types
│   │   └── server.d
│   │       └── kibana.conf
│   └── nginx.conf
└── README.md

5 directories, 9 files
```

- *docker-compose.yml*

    ```yml
    ---
    version: '2.4'
    services:
        elasticsearch:
            image: ${ELASTICSEARCH_IMAGE}
            restart: always
            environment:
                - 'node.name=HEYJUDE'
                - 'discovery.type=single-node'
                - 'bootstrap.memory_lock=true'
                - 'ES_JAVA_OPTS=-Xms256m -Xmx256m'
            ports:
                - 9200:9200
    #            - 9300:9300
            volumes:
                - type: bind
                  source: /var/lib/elasticsearch
                  target: /usr/share/elasticsearch/data
            networks:
                - net
            logging:
                driver: fluentd
                options:
                    fluentd-address: localhost:24224
                    fluentd-async-connect: 'true'
                    fluentd-retry-wait: '1s'
                    fluentd-max-retries: '30'
                    tag: ${LOG_OPT_TAG_PREFIX}.efk.elasticsearch
    
        kibana:
            image: ${KIBANA_IMAGE}
            restart: always
    #        ports:
    #            - 5601:5601
            networks:
                - net
            depends_on:
                - elasticsearch
            logging:
                driver: fluentd
                options:
                    fluentd-address: localhost:24224
                    fluentd-async-connect: 'true'
                    fluentd-retry-wait: '1s'
                    fluentd-max-retries: '30'
                    tag: ${LOG_OPT_TAG_PREFIX}.efk.kibana
    
        fluentd:
            image: ${FLUENTD_IMAGE}
            ports:
                - 127.0.0.1:24224:24224
    #            - 24224:24224/udp
            volumes:
                - ./fluentd/etc:/fluentd/etc
            networks:
                - net
            logging:
                driver: "json-file"
                options:
                    max-size: "1G"
                    max-file: "2"
    
        nginx:
            image: ${NGINX_IMAGE}
            restart: always
            ports:
                - 80:80
            volumes:
                - type: bind
                  source: ./nginx/nginx.conf
                  target: /etc/nginx/nginx.conf
                  read_only: true
                - type: bind
                  source: ./nginx/conf.d
                  target: /etc/nginx/conf.d
                  read_only: true
            networks:
                - net
            depends_on:
                - kibana
            logging:
                driver: fluentd
                options:
                    fluentd-address: localhost:24224
                    fluentd-async-connect: 'true'
                    fluentd-retry-wait: '1s'
                    fluentd-max-retries: '30'
                    tag: ${LOG_OPT_TAG_PREFIX}.efk.nginx
    networks:
        net:
            driver: bridge
    ```
    
- *.env*
    
    ```.env
    COMPOSE_PROJECT_NAME=efk
    
    ELASTICSEARCH_IMAGE=docker.elastic.co/elasticsearch/elasticsearch-oss:6.3.0
    KIBANA_IMAGE=docker.elastic.co/kibana/kibana-oss:6.3.0
    FLUENTD_IMAGE=qqbuby/fluentd:v1.2-es
    NGINX_IMAGE=nginx:1.13
    
    LOG_OPT_TAG_PREFIX=alpha
    ```
    
- *fluentd/etc/fluent.conf*

    For more information about `fluent.conf` file, see [https://docs.fluentd.org/v0.12/articles/config-file](https://docs.fluentd.org/v0.12/articles/config-file).
    
    ```conf
    <system>
      log_level warn
    </system>
    <source>
      @type forward
      port 24224
      bind 0.0.0.0
    </source>
    <match *.efk.nginx>
      @type rewrite_tag_filter
      <rule>
        key source
        pattern stdout
        tag ${tag}.access
      </rule>
      <rule>
        key source
        pattern stderr
        tag ${tag}.error
      </rule>
    </match>
    <filter *.efk.nginx.access>
      @type parser
      format nginx
      key_name log
    </filter>
    <filter *.efk.nginx.error>
      @type parser
      format /^(?<time>\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) \[(?<log_level>\w+)\] (?<pid>\d+).(?<tid>\d+): (?<message>.*)/
      key_name log
      time_format %Y/%m/%d %H:%M:%S
    </filter>
    <filter *.efk.elasticsearch>
      @type parser
      format /^\[(?<time>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2},\d{3})\]\[(?<log_level>\w+)\s*\]\[(?<category>(\w|\.)*)\s*\] \[(?<node_name>\w+)\]\s*(?<message>.*$)/
      key_name log
      time_format %Y-%m-%dT%H:%M:%S,%L
    </filter>
    <filter *.efk.kibana>
      @type parser
      format json
      key_name log
      time_key "@timestamp"
      time_format %Y-%m-%dT%H:%M:%SZ
    </filter>
    <match *.**>
      @type copy
      <store>
        @type elasticsearch
        host elasticsearch
        port 9200
        logstash_format true
        logstash_prefix fluentd
        logstash_dateformat %Y%m%d
        include_tag_key true
        type_name access_log
        tag_key @log_name
        flush_interval 5s
      </store>
      <store>
        @type stdout
      </store>
    </match>
    ```
- *nginx/nginx.conf*

   ```conf
    user  nginx;
    worker_processes  auto;
    
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;
    
    
    events {
        worker_connections  1024;
    }
    
    
    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;
    
        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent" "$http_x_forwarded_for"';
    
        access_log  /var/log/nginx/access.log  main;
    
        sendfile        on;
        #tcp_nopush     on;
    
        keepalive_timeout  65;
    
        #gzip  on;
    
        include /etc/nginx/conf.d/*.conf;
    }
    ```

- *nginx/conf.d/default.conf*

    ```conf
    include /etc/nginx/conf.d/server.d/*.conf;
    ```

- *nginx/conf.d/gzip.mime.types*

    ```conf
    gzip_types  text/plain text/css application/javascript application/xml text/xml application/json text/json image/svg+xml;
    ```


- *nginx/conf.d/server.d/kibana.conf*

    ```conf
    upstream kibana {
        server  kibana:5601;
    
        keepalive   16;
    }
    
    
    server {
        server_name             localhost;
        listen                  80 default;
    
        location / {
            proxy_pass      http://kibana;
    
            proxy_http_version              1.1;
            proxy_set_header Connection     "";
    
            send_timeout            120;
            proxy_send_timeout      120;
            proxy_read_timeout      120;
    
            proxy_set_header Host               $http_host;
            proxy_set_header X-Real-IP          $remote_addr;
            proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto  $scheme;
    
            gzip        on;
            include     /etc/nginx/conf.d/gzip.mime.types;
        }
    }
    ```

> The fluentd image [qqbuby/fluentd:v1.2-es](https://github.com/qqbuby/fluentd-docker) contains two fluentd plugins, fluent-plugin-elasticsearch and fluent-plugin-rewrite-tag-filter.
>
> ```dockerfile
> FROM fluent/fluentd:v1.2
> 
> RUN apk add --update --virtual .build-deps \
>     sudo build-base ruby-dev \
>  && sudo gem install \
>         fluent-plugin-elasticsearch \
>         fluent-plugin-rewrite-tag-filter \
>  && sudo gem sources --clear-all \
>  && apk del .build-deps \
>  && rm -rf /var/cache/apk/* \
>            /home/fluent/.gem/ruby/2.4.0/cache/*.gem
> ```

> By default, Elasticsearch runs inside the container as user `elasticsearch` using uid:gid `1000:1000`. 
> 
> If you are bind-mouting a local directory or file, ensure it is readable by this user, while the data and log dirs additionally require write access. A good strategy is to grant group access to gid `1000` or `0` for the local directory. As an example, to prepare a local directory for storing data through a bind-mout:
> 
> ```sh
> mkdir esdatadir
> chmod g+rwx esdatadir
> chgrp 1000 esdatadir
> ```
> 
> For more information, see [https://www.elastic.co/guide/en/elasticsearch/reference/6.3/docker.html](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/docker.html)

Now let's create ES data directory and start our EFK services.

1. Create ES data directory.

    ```sh
    $ sudo mkdir -p /var/lib/elasticsearch/
    $ sudo chown 1000:1000 /var/lib/elasticsearch/
    ```
1. Use `docker-compose` to start services

    ```sh
    $ docker-compose up
    Creating network "efk_net" with driver "bridge"
    Creating efk_fluentd_1       ... done
    Creating efk_elasticsearch_1 ... done
    Creating efk_kibana_1        ... done
    Creating efk_nginx_1         ... done
    Attaching to efk_fluentd_1, efk_elasticsearch_1, efk_kibana_1, efk_nginx_1
    elasticsearch_1  | WARNING: no logs are available with the 'fluentd' log driver
    kibana_1         | WARNING: no logs are available with the 'fluentd' log driver
    nginx_1          | WARNING: no logs are available with the 'fluentd' log driver
    
    . . .

    fluentd_1        | 2018-06-29 09:21:09.861000000 +0000 alpha.efk.elasticsearch: {"log_level":"INFO","category":"o.e.c.m.MetaDataMappingService","node_name":"HEYJUDE","message":"[fluentd-20180629/iZYKqcauT3m1wMiHrCa48w] update_mapping [access_log]"}
    fluentd_1        | 2018-06-29 09:21:11.992000000 +0000 alpha.efk.elasticsearch: {"log_level":"INFO","category":"o.e.c.m.MetaDataMappingService","node_name":"HEYJUDE","message":"[fluentd-20180629/iZYKqcauT3m1wMiHrCa48w] update_mapping [access_log]"}
    ```

1. Please go to `http://localhost` with your browser and follow the Kibana [documentation](https://www.elastic.co/guide/en/kibana/6.3/tutorial-define-index.html#tutorial-define-index) to define your index pattern with `fluentd-*`,

    ![Create Index Pattern](/assets/efk/define-index-pattern.png)

1. Fllow the Kibana [documentation](https://www.elastic.co/guide/en/kibana/6.3/discover.html) to explore your logging data for the Discover page.


    ![Create Index Pattern](/assets/efk/discover-logging-data.png)

### Resources

1. ELK Stack: Elasticsearch, Logstash, Kibana, [https://www.elastic.co/elk-stack](https://www.elastic.co/elk-stack)
1. Elasticsearch (Store, Search, and Analyze) Reference \[6.3\], [https://www.elastic.co/guide/en/elasticsearch/reference/6.3/index.html](https://www.elastic.co/guide/en/elasticsearch/reference/6.3/index.html)
1. Logstash (Collect, Enrich, and Transport) Reference \[6.3\], [https://www.elastic.co/guide/en/logstash/6.3/index.html](https://www.elastic.co/guide/en/logstash/6.3/index.html)
1. Kibana (Explore, Visualize, and Share) Reference \[6.3\], [https://www.elastic.co/guide/en/kibana/6.3/index.html](https://www.elastic.co/guide/en/kibana/6.3/index.html)
1. Fluentd vs. LogStash: A Feature Comparison, [https://www.loomsystems.com/blog/single-post/2017/01/30/a-comparison-of-fluentd-vs-logstash-log-collector](https://www.loomsystems.com/blog/single-post/2017/01/30/a-comparison-of-fluentd-vs-logstash-log-collector)
1. Fluentd vs. Logstash: A Comparison of Log Collectors, [https://logz.io/blog/fluentd-logstash/](https://logz.io/blog/fluentd-logstash/)
1. Fluentd \| Open Source Data Collector \| Unified Logging Layer, [https://www.fluentd.org/](https://www.fluentd.org/)
1. View logs for a container or service \| Docker Documentation, [https://docs.docker.com/config/containers/logging/](https://docs.docker.com/config/containers/logging/)
1. Configure logging drivers \| Docker Documentation, [https://docs.docker.com/config/containers/logging/configure/](https://docs.docker.com/config/containers/logging/configure/)
1. JSON File logging driver \| Docker Documentation, [https://docs.docker.com/config/containers/logging/json-file/](https://docs.docker.com/config/containers/logging/json-file/)
1. Fluentd logging driver \| Docker Documentation, [https://docs.docker.com/config/containers/logging/fluentd/](https://docs.docker.com/config/containers/logging/fluentd/)
1. Configuration File Syntax \| Fluentd, [https://docs.fluentd.org/v0.12/articles/config-file](https://docs.fluentd.org/v0.12/articles/config-file)
1. Format section configurations \| Fluentd, [https://docs.fluentd.org/v1.0/articles/format-section](https://docs.fluentd.org/v1.0/articles/format-section)
1. regexp Parser Plugin \| Fluentd, [https://docs.fluentd.org/v1.0/articles/parser_regexp](https://docs.fluentd.org/v1.0/articles/parser_regexp)
