package com.redhat.training;

import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.redhat.training.service.AdderService;
import com.redhat.training.service.MultiplierService;
import com.redhat.training.service.SolverService;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.jaegertracing.internal.JaegerSpanContext;
import io.opentracing.SpanContext;
import io.opentracing.Tracer;
import io.smallrye.opentracing.contrib.resolver.TracerResolver;

import javax.jms.ConnectionFactory;
import javax.jms.JMSContext;
import javax.jms.JMSException;
import javax.jms.JMSRuntimeException;
import javax.jms.Message;
import javax.jms.Session;

public class SolverResource implements SolverService {
    final Logger log = LoggerFactory.getLogger(SolverResource.class);

    @Inject
    Tracer tracer;

    @Inject
    @RestClient
    AdderService adderService;

    @Inject
    @RestClient
    MultiplierService multiplierService;

    static final Pattern multiplyPattern = Pattern.compile("(.+)\\*(.+)");
    static final Pattern addPattern = Pattern.compile("(.+)\\+(.+)");

    @Override
    @GET
    @Path("{equation}")
    @Produces(MediaType.TEXT_PLAIN)
    public Float solve(@PathParam("equation") String equation) {
        log.info("Solving '{}'", equation);

        try {
            return Float.valueOf(equation);
        } catch (NumberFormatException e) {
            Matcher addMatcher = addPattern.matcher(equation);
            if (addMatcher.matches()) {

                Float result = adderService.add(addMatcher.group(1), addMatcher.group(2));
                return result;
            
            }
            Matcher multiplyMatcher = multiplyPattern.matcher(equation);
            if (multiplyMatcher.matches()) {

                Float result = multiplierService.multiply(multiplyMatcher.group(1), multiplyMatcher.group(2));
                return result;
            
            } else {
                TracerResolver.resolveTracer().activeSpan().setBaggageItem("answer", "Unable to parse: " + equation);
                throw new WebApplicationException(
                        Response.status(Response.Status.BAD_REQUEST).entity("Unable to parse: " + equation).build());
            }
        }
    }

    @Override
    @GET
    @Path("{equation}")
    @Produces(MediaType.TEXT_PLAIN)
    public String solveAndGetTraceId(@PathParam("equation") String equation) {
        log.info("Solving '{}'", equation);

        String traceId = "none";

        final SpanContext spanContext = tracer.scopeManager().activeSpan().context();
        if (spanContext instanceof JaegerSpanContext) {
            traceId = ((JaegerSpanContext) spanContext).getTraceId();
        }

        TracerResolver.resolveTracer().activeSpan().setTag("traceId", traceId);
        TracerResolver.resolveTracer().activeSpan().setTag("tagMessage", "this is an awesome message");
        TracerResolver.resolveTracer().activeSpan().setBaggageItem("traceId", traceId);

        String result = solve(equation).toString();

        TracerResolver.resolveTracer().activeSpan().setBaggageItem("answer", equation + " = " + result);

        String message = "traceId: " + traceId + ", " + result;
        sendMessage(message);
        receiveMessage();
        return message;
    }

    @Inject
    ConnectionFactory connectionFactory;

    public void sendMessage(String message) {
        try (JMSContext context = connectionFactory.createContext(Session.AUTO_ACKNOWLEDGE)){
            context.createProducer().send(context.createQueue("exampleQueue"), message);
        } catch (JMSRuntimeException ex) {
            // handle exception (details omitted)
        }
    }

    public void receiveMessage() {
        try (JMSContext context = connectionFactory.createContext(Session.AUTO_ACKNOWLEDGE)) {
            javax.jms.JMSConsumer consumer = context.createConsumer(context.createQueue("exampleQueue"));
            Message message = consumer.receive();
            if (message == null) {
                return;
            }
            System.out.println(message);
            message.acknowledge();
        } catch (JMSException e) {
            throw new RuntimeException(e);
        }
    }
}
