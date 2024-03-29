---
layout: post
title: How to produce and consume events on Kafka with Spring Stream
date: 2020-11-18 16:07:04 +0800
categories: ['spring']
tags: ['spring']
date: 2024-01-06 17:37:25 +0800
---

- TOC
{:toc}

## How to produce and consume events on Kafka with Spring Stream?

> How to produce and consume events on Kafka with Spring Stream?

Apache Kafka is a highly popular option for data streaming. Spring Cloud Stream is a framework built upon Spring Boot for building message-driven microservice applications and it provides built-in capabilities to work with Apache Kafka as the underlying message broker.

Here's a basic guide on how to produce and consume events on Kafka using Spring Cloud Stream:

1. **Set Up Kafka:**
First you need to have a working Kafka instance. You can either install it on your machine or run it in a docker container.

2. **Create Spring Boot Application:**
You can create a Spring Boot application using Spring Initializr.

3. **Add Required Dependencies:**
You need to have the following dependencies in your `pom.xml` or `build.gradle` file.

    For Maven:
    ```xml
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-stream-kafka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-stream</artifactId>
        </dependency>
    </dependencies>
    ```

    For Gradle:
    ```gradle
    dependencies {
        implementation 'org.springframework.cloud:spring-cloud-starter-stream-kafka'
        implementation 'org.springframework.cloud:spring-cloud-stream'
    }
    ```

4. **Configure the Application:**
In `application.properties` or `application.yml` file you need to set the Kafka broker address, the name of the topic, and other parameters if necessary.

    ```yml
    spring:
      cloud:
        stream:
          bindings:
            output:
              destination: topic-name
              binder: kafka
          kafka:
            binder:
              brokers: localhost:9092
    ```

5. **Create a Source:**
A source is a channel through which the data flows out to the Kafka broker. Annotate an output channel with `@Output`.

    ```java
    public interface ProducerBinding {

        String OUTPUT = "output";

        @Output(OUTPUT)
        MessageChannel output();

    }
    ```

6. **Publish Messages:**
Inject the source in your service, create a message and send it using `output().send(MessageBuilder.withPayload(yourMessage).build())`.

    ```java
    @Autowired
    private ProducerBinding source;

    public void publish(String message){
        source.output().send(MessageBuilder.withPayload(message).build());
    }
    ```

7. **Create a Sink:**
A sink is a channel through which the data flows into the application from Kafka. Annotate an input channel with `@Input`.

    ```java
    public interface ConsumerBinding {

        String INPUT = "input";

        @Input(INPUT)
        SubscribableChannel input();

    }
    ```

8. **Consume Messages:**
Create a consumer class where you listen to the messages. Annotate a method with `@StreamListener` to receive messages.

    ```java
    @Service
    public class ConsumerService {

        @StreamListener(ConsumerBinding.INPUT)
        public void handle(String value) {
           // Process the message
           System.out.println("Received: " + value);
        }
    }
    ```

9. **Run the Application:**
Now, you can run your Spring Boot application. It should be able to send and receive the messages from Kafka.

Remember, this is just a basic guide that covers the core concepts. There are more configurations and details that you can explore as per your use case. Make sure to refer to the official documentations for both Spring Cloud Stream and Apache Kafka.

## What's the bindings and binder?

> What's the bindings and binder?

Both "bindings" and "binder" are terms used within the Spring Cloud Stream (SCS) framework, and they're central to understanding how Spring Cloud Stream operates.

1. **Bindings**: In Spring Cloud Stream, a binding is a bridge between your application's message channels and the message broker (like Apache Kafka or RabbitMQ). They form the core abstraction in Spring Cloud Stream programming model.

    The concept of 'binding' is about connecting your application with the messaging system via a Message Channel (a key abstraction in Spring Integration, where 'input' or 'output' represent an inbound or outbound entity).

    This wiring is auto-created by Spring Cloud Stream. In simple terms, SCS provides connectivity between your application and messaging middleware, and this connectivity is facilitated by 'bindings'.

    For example, if you define a binding named "output" as in the previous example, Spring Cloud Stream will know that a channel named "output" should be used to dispatch the messages to the messaging middleware.

2. **Binder**: The Binder is the component of Spring Cloud Stream responsible for providing the necessary configuration and implementation for the connection to the messaging system.

    Binders exist for various message brokers, including but not limited to RabbitMQ, Apache Kafka, Amazon Kinesis, etc. The binder brings the bits that are needed to connect the application to the specific message broker and acts as an adapter layer between your application and the messaging system.

    When Spring Cloud Stream receives a message that needs to be published, it's the binder which takes care of how to connect to the broker, how to serialize the message, where to publish it (topics, routing key, etc.), and so on. It also deals with how to read and convert incoming messages before sending them to your application.

Through this system of bindings and binders, Spring Cloud Stream abstracts away the specifics of the underlying message brokers, allowing developers to focus on writing the business logic.

'''

The application.yml file is a configuration file used by Spring Boot applications. It's a space-sensitive file in YAML format that Spring Boot reads at launch to configure properties of the application.

In the example you referenced:

```yml
spring:
  cloud:
    stream:
      bindings:
        output:
          destination: topic-name
          binder: kafka
      kafka:
        binder:
          brokers: localhost:9092
```

Here's the explanation for this:

1. `spring`: This is the root configuration prefix for all Spring Boot applications.

2. `cloud`: This is the specific configuration prefix for all Spring Cloud applications.

3. `stream`: This is the specific configuration prefix from the Spring Cloud Stream project. It's used to configure the Spring Cloud Stream properties.

4. `bindings`: These are the definitions of your input and output channels. In your case, you're defining an output channel.

    - `output`: This is the name of your output channel. It corresponds to the `OUTPUT` constant value ('output') defined in your code.

       - `destination`: This is the name of the Kafka topic where the events will be produced. Messages sent to the 'output' channel will end up in this topic on the Kafka broker.

       - `binder`: This defines the binder configuration that this binding should be created from. This is optional and if not present, the default binder configuration will be used.

5. `kafka`: This is for Kafka-specific configuration.

    - `binder`: It holds properties for kafka binder.

        - `brokers`: This is the hostname and port for your Kafka broker(s). The application will connect to Kafka using these details.

Remember that YAML files are whitespace and indentation sensitive. Misalignment may lead to an error or properties may not be assigned correctly.

## What's the default binder meaning?

> What's the default binder meaning?

In Spring Cloud Stream, the binder is the piece that ties your application to the specific message broker (like RabbitMQ, Kafka, Google Pub-Sub, etc.). It does this by providing the necessary configuration and implementation of the broker-specific code.

When you define the 'binder' property for a specific binding, you’re telling Spring Cloud Stream to use that as the binder (and hence the message broker) for that binding.

However, when you don't specify a 'binder' property for a binding, Spring Cloud Stream will use the 'defaultBinder' that's defined in your application configurations.

For example, consider a scenario where your application connects to two different message brokers - Kafka and RabbitMQ. In your configurations, you can define both Kafka and RabbitMQ binders, but also specify the Kafka binder as the 'defaultBinder'.

In the `application.yaml` file:
```yaml
spring:
  cloud:
    stream:
      defaultBinder: kafka
      kafka:
        binder:
          brokers: localhost:9092
      rabbitmq:
        binder:
          address: localhost
...
```
Any binding definitions that don't explicitly set the 'binder' attribute will automatically use the Kafka binder because that's defined as the 'defaultBinder'. However, if you want a particular channel to use RabbitMQ instead, you can achieve that by explicitly stating so in the 'binder' attribute for that specific channel.

```yaml
spring:
  cloud:
    stream:
      bindings:
        myOutputChannel:
          destination: mytopic
        myRabbitChannel:
          destination: myqueue
          binder: rabbitmq
```
In this example, `myOutputChannel` will use Kafka as the binder (as Kafka is defined as the default binder), and `myRabbitChannel` will use the RabbitMQ as the binder (as it's explicitly defined for this binding).

## What if there is only ond binder like Kafka? Should we need to specify the defaultBinder explicitly?

> What if there is only ond binder like Kafka? Should we need to specify the defaultBinder explicitly?

No, if you only have one binder (like Kafka) in your application, you don't need to specify it as the 'defaultBinder' explicitly.

Spring Cloud Stream will automatically use the only available binder for your application. If you have only one binder configuration in your classpath, then Spring Cloud Stream smartly understands that to be the default binder for your application.

Here is an example configuration where no default binder is specified, and there is only one binder, Kafka:

```yaml
spring:
  cloud:
    stream:
      kafka:
        binder:
          brokers: localhost:9092
      bindings:
        output:
          destination: topic-name
```

In this case, `spring.cloud.stream.kafka.binder.brokers` property maps to the Kafka broker, and `spring.cloud.stream.bindings.output.destination` specifies the name of the topic on the Kafka broker from which the messages will be published to.

Your application will use Kafka as the binder since it's the only binder available in the setup, and you don't need to specify it as a default binder explicitly.

## The sample code you used by MessageChannel etc, nowdays SCS will use the spring cloud functions like Supplier, Consumer etc.

> The sample code you used by MessageChannel etc, nowdays SCS will use the spring cloud functions like Supplier, Consumer etc.

You're correct. The Spring Cloud Stream framework has moved toward a more functional programming model, using `java.util.function`'s `Supplier`, `Consumer`, and `Function` for message handling. This is especially recommended for Spring Cloud Stream 3.0 and above. Here's a quick sketch of how to use them with your Apache Kafka setup:

**Producer:**

Firstly, define a `Supplier` bean for producing a message:

```java
@Bean
public Supplier<String> produce() {
    return () -> {
        // generate message content
        String message = "Hello, Kafka!";
        return message;
    };
}
```

In your `application.yml` configure the output stream for the `Supplier`:

```yml
spring:
  cloud:
    function:
      definition: produce
    stream:
      bindings:
        produce-out-0:
          destination: topic-name
      kafka:
        binder:
          brokers: localhost:9092
```

**Consumer:**

Next, declare a `Consumer` to consume messages from a broker:

```java
@Bean
public Consumer<String> consume() {
    return message -> {
        // process message content
        System.out.println("Received: " + message);
    };
}
```

In your `application.yml`, configure the input stream for the `Consumer`:

```yml
spring:
  cloud:
    function:
      definition: consume
    stream:
      bindings:
        consume-in-0:
          destination: topic-name
      kafka:
        binder:
          brokers: localhost:9092
```

By convention, SCS uses function names as the binding names: 'produce-out-0' and 'consume-in-0'. '0' is the index in case you have multiple inputs or outputs. But you can change these via Spring Cloud Stream's 'spring.cloud.stream.function.bindings.*' property.

In the latest functional programming model, you don't explicitly deal with message channels or use annotations such as `@Input` or `@Output`.
The methods signature implies whether the application is intended to be used for source/sink/processor.

Remember, these examples are just basic scenarios and more complicated scenarios like content-type negotiation or error handling in Apache Kafka with Spring Cloud Stream may need additional steps.

## How does the produce function work? I mean how it is triggered to send messages?

> How does the produce function work? I mean how it is triggered to send messages?

Great question! The Supplier function in Spring Cloud Stream is used to produce or generate messages that need to be sent to the message broker system, like Apache Kafka or RabbitMQ.

However, a `Supplier` in Spring Cloud Stream is not called or triggered directly. Instead, the framework does it automatically for you at regular intervals. This interval is by default set at 1 message/second, but it can be easily configured using the property `spring.cloud.stream.poller.fixed-delay`.

Here's an example of how to adjust the poller's interval:

```yml
spring:
  cloud:
    stream:
      poller:
        fixed-delay: 5000
```

This configuration will trigger the `Supplier` function approximately every 5 seconds (value is in milliseconds) to generate a new message.

Moreover, when the application starts up, Spring Cloud Stream automatically sets up a background loop that calls the `Supplier.get()` method at the specified rate (or the default rate, if no rate is specified) and sends its output to the specified message broker destination.

Note: The Supplier function is generally used in source applications where you are producing messages and not consuming any.

## What if we want to send a message manually, like when we receive a user login event on a Rest Controller?

> What if we want to send a message manually, like when we receive a user login event on a Rest Controller?

Indeed, the Supplier function is automatically triggered at regular intervals which is not an ideal scenario when you want to produce a message based on a certain event - like a user login event, as in your example.

In such a case, you typically use a `MessageChannel` to manually send messages. However, with the functional programming model, you could use a `StreamBridge`. The `StreamBridge` is a utility that is automatically available in the context which you can `Autowire` and use it anywhere in your application to dynamically send messages to a destination.

Here's an example of how to use `StreamBridge`:

```java
@RestController
public class LoginController {
    private final StreamBridge streamBridge;

    @Autowired
    public LoginController(StreamBridge streamBridge) {
        this.streamBridge = streamBridge;
    }

    @PostMapping("/login")
    public String loginUser(@RequestBody User user) {
        // validate and login user, generate response
        // ...

        // send a message when a user logs in
        streamBridge.send("produce-out-0", user);

        return "Login Successful!";
    }
}
```
In this example, each time the "/login" endpoint is hit, a `User` object would be sent to the output channel "produce-out-0".

Remember to configure the output binding in your `application.yml` appropriately:

```yaml
spring:
  cloud:
    stream:
      bindings:
        produce-out-0:
          destination: topic-name
      kafka:
        binder:
          brokers: localhost:9092
```

The `StreamBridge` utility provides a flexible way to produce messages from anywhere within your application, making it a great choice when you need to manually send messages in a Spring Cloud Stream application.

## What if there are multiple functions, but used to be handle diff topics?

> What if there are multiple functions, but used to be handle diff topics?

If you have multiple functions corresponding to different topics (destinations), you can easily configure them in Spring Cloud Stream.

Each `java.util.function.Function`, `java.util.function.Consumer` or `java.util.function.Supplier` bean can correspond to a different binder destination.

Here's an example:

**Producer Function Beans:**

```java
@Bean
public Supplier<String> produceUserEvent() {
    return () -> {
        // generate user event message content
        String message = "User event";
        return message;
    };
}

@Bean
public Supplier<String> produceProductEvent() {
    return () -> {
        // generate product event message content
        String message = "Product event";
        return message;
    };
}
```

**Consumer Function Beans:**

```java
@Bean
public Consumer<String> consumeUserEvent() {
    return message -> {
        // process user event message content
        System.out.println("Received user event: " + message);
    };
}

@Bean
public Consumer<String> consumeProductEvent() {
    return message -> {
        // process product event message content
        System.out.println("Received product event: " + message);
    };
}
```

**Configuration in `application.yml`:**

You can declare the bindings and specific destinations in your `application.yml`:

```yml
spring:
  cloud:
    function:
      definition: produceUserEvent;consumeUserEvent;produceProductEvent;consumeProductEvent
    stream:
      bindings:
        produceUserEvent-out-0:
          destination: user-events
        consumeUserEvent-in-0:
          destination: user-events
        produceProductEvent-out-0:
          destination: product-events
        consumeProductEvent-in-0:
          destination: product-events
      kafka:
        binder:
          brokers: localhost:9092
```

In this example, `produceUserEvent-out-0` and `consumeUserEvent-in-0` are used to produce and consume messages for "user events", while `produceProductEvent-out-0` and `consumeProductEvent-in-0` are used to produce and consume "product events". Each `-out-0` or `-in-0` suffix represents the output or input channel binding for that function.

In the end, each function serves its own topic, producing or consuming different set of data, while having separate responsibility.

> got it, it seems that the function.definition is used to tell the SCS to indentify the handlers?
q
* That's correct. The `spring.cloud.function.definition` property in the application configuration can be used to specify the beans - either `Supplier`, `Consumer`, or `Function` - that Spring Cloud Stream should bind to messaging channels.

If you have multiple function beans in your Spring application context, but you only want to use some of them for messaging purposes, this is where `spring.cloud.function.definition` becomes handy.

The property takes a semi-colon separated list of the bean names to be bound to the messaging system.

For example:
```yml
spring:
  cloud:
    function:
      definition: myFunction;myConsumer;mySupplier
```

In this example, `myFunction`, `myConsumer`, `mySupplier` are the names of `Function`, `Consumer`, `Supplier` beans respectively. Spring Cloud Stream will bind only these beans to messaging channels according to the output/input bindings specified elsewhere in your properties.

It's important to remember that the function definition should have the same name as the function bean in the application. If your function bean is defined as follows:

```java
@Bean
public Consumer<String> myConsumer() {
  return data -> { /*...*/ };
}
```

You should use `myConsumer` in the `spring.cloud.function.definition`.

## How to compiste functions to handle a topic?

> How to compiste functions to handle a topic?

* Composing functions is a powerful feature of Spring Cloud Stream that allows multiple operations to be performed on a message in a sequence. You can chain multiple functions together to process the input data.

To compose functions, you use the pipe symbol `|`, similar to how you would in a Unix/Linux command line. Here's an example:

```java
@Bean
public Function<String, String> firstFunction() {
    return input -> input.toUpperCase();
}

@Bean
public Function<String, String> secondFunction() {
    return input -> "Message: " + input;
}
```

And in your application configuration file:

```yaml
spring:
  cloud:
    function:
      definition: firstFunction|secondFunction
```

The `firstFunction` will be applied first, and then its output will be used as the input to the `secondFunction`. This way, when a message comes in, it'll be first converted to uppercase by `firstFunction`, and then `secondFunction` will prepended "Message: " to it.

Keep in mind, when composing functions:

* Each function must "match" with its neighbouring function - the output type of one function should be the same as the input type of the next.
* Create separate Application Configuration file (application.yml or application.properties) for each binder (input or output) when using the composed function. The binding destination should match for both producer and consumer otherwise producer will not be able to send and the consumer won't consume the messages.
* Composing two or more consumers (`Consumer<A> | Consumer<B>`) or two or more suppliers (`Supplier<A> | Supplier<B>`) is not valid as per Spring Cloud Stream documentation because the supplier does not consume any input, and the consumer does not produce any output.
* If message types do not match, a converter can be used to typecast them.

## How does the composite functions to be bound to a destination?

> How does the composite functions to be bound to a destination?

The composed (composite) functions can be bound to a destination (topic) through the application configuration file (like application.yml) in Spring Cloud Stream.

The basic procedure is to define the destination in the `spring.cloud.stream.bindings.<functionName>-in-0.destination` for input bindings and `spring.cloud.stream.bindings.<functionName>-out-0.destination` for output bindings, where `<functionName>` is the composed function name.

For example, consider two functions: `uppercase` and `prefix` which you have composed as `processFunction`:

```java
@Bean
public Function<String, String> uppercase() {
    return String::toUpperCase;
}

@Bean
public Function<String, String> prefix() {
    return input -> "Hello " + input;
}
```

You define the composite function in your `spring.cloud.function.definition` like this:

```yaml
spring:
  cloud:
    function:
      definition: processFunction
```

To bind the composite function to a topic, define the input and output bindings:

```yaml
spring:
  cloud:
    stream:
      bindings:
        processFunction-in-0:
          destination: input-topic
        processFunction-out-0:
          destination: output-topic
```

In this setup, messages coming in from `input-topic` will trigger the composite function `processFunction` (which consists of `uppercase` and `prefix`) and the results will be sent to `output-topic`.

Remember, the `bindings` property should match the function name. So if your composed function is called `processFunction`, you should have your bindings as `processFunction-in-0` and `processFunction-out-0`.

> I didn't see any configuration about the realtion between processFunction and the uppercase and prefix.

I apologize for the confusion, I should have clarified that in the explanation. The processFunction was intended as a placeholder name in the bindings configuration for the composed function (uppercase|prefix).

The binding happens based on the `spring.cloud.function.definition` property. The composed function is defined as the concatenation of the beans you want to compose (uppercase|prefix, in this case) in the `spring.cloud.function.definition` property.

Here's how you can specify `uppercase` and `prefix` functions and bind them to input and output channels:

```java
@Bean
public Function<String, String> uppercase() {
    return String::toUpperCase;
}

@Bean
public Function<String, String> prefix() {
    return input -> "Hello " + input;
}
```

In your `application.yml`, you compose them together:

```yaml
spring:
  cloud:
    function:
      definition: uppercase|prefix
  cloud:
    stream:
      bindings:
        uppercase|prefix-in-0:
          destination: input-topic
        uppercase|prefix-out-0:
          destination: output-topic
```
In this setup, when a message comes in from the `input-topic`, it is first processed by the `uppercase` function, and then it's output is processed by the `prefix` function, and then the final output is sent to `output-topic`.

The use of `|` (pipe) character enables function composition, where the output of one function becomes the input of the next one in line.
