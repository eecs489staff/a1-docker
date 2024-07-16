package org.onosproject.fwd489;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Deactivate;
import org.onlab.packet.Ethernet;
import org.onlab.packet.Ip4Address;
import org.onlab.packet.IPv4;
import org.onosproject.cfg.ComponentConfigService;
import org.onosproject.core.ApplicationId;
import org.onosproject.core.CoreService;
import org.onosproject.net.ConnectPoint;
import org.onosproject.net.PortNumber;
import org.onosproject.net.packet.PacketContext;
import org.onosproject.net.packet.PacketProcessor;
import org.onosproject.net.packet.PacketService;
import org.onosproject.net.packet.PacketPriority;
import org.onosproject.net.flow.DefaultFlowRule;
import org.onosproject.net.flow.FlowRule;
import org.onosproject.net.flow.FlowRuleService;
import org.onosproject.net.flow.DefaultTrafficSelector;
import org.onosproject.net.flow.DefaultTrafficTreatment;
import org.onosproject.net.flow.TrafficSelector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

@Component(immediate = true)
public class AppComponent {

    private final Logger log = LoggerFactory.getLogger(getClass());

    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected ComponentConfigService cfgService;

    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected CoreService coreService;

    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected FlowRuleService flowRuleService;

    @Reference(cardinality = ReferenceCardinality.MANDATORY)
    protected PacketService packetService;

    private ApplicationId appId;
    private ReactivePacketProcessor processor = new ReactivePacketProcessor();
    private Map<Ip4Address, PortNumber> routingTable = new HashMap<>(); // Static routing table

    @Activate
    protected void activate() {
        appId = coreService.registerApplication("org.onosproject.fwd489");

        // Initialize the routing table
        initializeRoutingTable();

        // Request packet intercepts
        packetService.addProcessor(processor, PacketProcessor.director(2));
        requestPackets();

        log.info("Started fwd489 application with App ID: {}", appId);
    }

    @Deactivate
    protected void deactivate() {
        packetService.removeProcessor(processor);
        processor = null;
        log.info("Stopped fwd489 application");
    }

    private void requestPackets() {
        TrafficSelector.Builder selector = DefaultTrafficSelector.builder();
        packetService.requestPackets(selector.matchEthType(Ethernet.TYPE_ARP).build(), PacketPriority.REACTIVE, appId);
        packetService.requestPackets(selector.matchEthType(Ethernet.TYPE_IPV4).build(), PacketPriority.REACTIVE, appId);
        log.info("Packet requests issued for ARP and IPv4");
    }

    private void initializeRoutingTable() {
        // Routing table entries for s1
        routingTable.put(Ip4Address.valueOf("10.0.0.1"), PortNumber.portNumber(1)); // h1
        routingTable.put(Ip4Address.valueOf("10.0.0.2"), PortNumber.portNumber(2)); // h2
        routingTable.put(Ip4Address.valueOf("10.0.0.5"), PortNumber.portNumber(3)); // h5
        routingTable.put(Ip4Address.valueOf("10.0.0.3"), PortNumber.portNumber(4)); // h3 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.4"), PortNumber.portNumber(4)); // h4 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.7"), PortNumber.portNumber(4)); // h7 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.8"), PortNumber.portNumber(4)); // h8 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.6"), PortNumber.portNumber(4)); // h6 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.9"), PortNumber.portNumber(4)); // h9 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.10"), PortNumber.portNumber(4)); // h10 via s2

        // Routing table entries for s2
        routingTable.put(Ip4Address.valueOf("10.0.0.3"), PortNumber.portNumber(1)); // h3
        routingTable.put(Ip4Address.valueOf("10.0.0.4"), PortNumber.portNumber(2)); // h4 via s3
        routingTable.put(Ip4Address.valueOf("10.0.0.7"), PortNumber.portNumber(3)); // h7 via s4
        routingTable.put(Ip4Address.valueOf("10.0.0.8"), PortNumber.portNumber(2)); // h8 via s3 and s5
        routingTable.put(Ip4Address.valueOf("10.0.0.6"), PortNumber.portNumber(2)); // h6 via s3 and s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.9"), PortNumber.portNumber(2)); // h9 via s3 and s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.10"), PortNumber.portNumber(2)); // h10 via s3 and s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.1"), PortNumber.portNumber(4)); // h1 via s1
        routingTable.put(Ip4Address.valueOf("10.0.0.2"), PortNumber.portNumber(4)); // h2 via s1
        routingTable.put(Ip4Address.valueOf("10.0.0.5"), PortNumber.portNumber(4)); // h5 via s1

        // Routing table entries for s3
        routingTable.put(Ip4Address.valueOf("10.0.0.4"), PortNumber.portNumber(1)); // h4
        routingTable.put(Ip4Address.valueOf("10.0.0.8"), PortNumber.portNumber(2)); // h8 via s5
        routingTable.put(Ip4Address.valueOf("10.0.0.6"), PortNumber.portNumber(2)); // h6 via s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.9"), PortNumber.portNumber(2)); // h9 via s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.10"), PortNumber.portNumber(2)); // h10 via s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.1"), PortNumber.portNumber(3)); // h1 via s2 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.2"), PortNumber.portNumber(3)); // h2 via s2 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.5"), PortNumber.portNumber(3)); // h5 via s2 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.3"), PortNumber.portNumber(3)); // h3 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.7"), PortNumber.portNumber(3)); // h7 via s2 and s4

        // Routing table entries for s4
        routingTable.put(Ip4Address.valueOf("10.0.0.7"), PortNumber.portNumber(1)); // h7
        routingTable.put(Ip4Address.valueOf("10.0.0.8"), PortNumber.portNumber(2)); // h8 via s5
        routingTable.put(Ip4Address.valueOf("10.0.0.6"), PortNumber.portNumber(2)); // h6 via s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.9"), PortNumber.portNumber(2)); // h9 via s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.10"), PortNumber.portNumber(2)); // h10 via s5 and s6
        routingTable.put(Ip4Address.valueOf("10.0.0.1"), PortNumber.portNumber(3)); // h1 via s2 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.2"), PortNumber.portNumber(3)); // h2 via s2 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.5"), PortNumber.portNumber(3)); // h5 via s2 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.3"), PortNumber.portNumber(3)); // h3 via s2
        routingTable.put(Ip4Address.valueOf("10.0.0.4"), PortNumber.portNumber(3)); // h4 via s3

        // Routing table entries for s5
        routingTable.put(Ip4Address.valueOf("10.0.0.8"), PortNumber.portNumber(1)); // h8
        routingTable.put(Ip4Address.valueOf("10.0.0.6"), PortNumber.portNumber(2)); // h6 via s6
        routingTable.put(Ip4Address.valueOf("10.0.0.9"), PortNumber.portNumber(2)); // h9 via s6
        routingTable.put(Ip4Address.valueOf("10.0.0.10"), PortNumber.portNumber(2)); // h10 via s6
        routingTable.put(Ip4Address.valueOf("10.0.0.1"), PortNumber.portNumber(3)); // h1 via s3 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.2"), PortNumber.portNumber(3)); // h2 via s3 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.5"), PortNumber.portNumber(3)); // h5 via s3 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.3"), PortNumber.portNumber(3)); // h3 via s3
        routingTable.put(Ip4Address.valueOf("10.0.0.4"), PortNumber.portNumber(3)); // h4 via s3
        routingTable.put(Ip4Address.valueOf("10.0.0.7"), PortNumber.portNumber(3)); // h7 via s2 and s4

        // Routing table entries for s6
        routingTable.put(Ip4Address.valueOf("10.0.0.6"), PortNumber.portNumber(1)); // h6
        routingTable.put(Ip4Address.valueOf("10.0.0.9"), PortNumber.portNumber(2)); // h9
        routingTable.put(Ip4Address.valueOf("10.0.0.10"), PortNumber.portNumber(3)); // h10
        routingTable.put(Ip4Address.valueOf("10.0.0.8"), PortNumber.portNumber(4)); // h8 via s5
        routingTable.put(Ip4Address.valueOf("10.0.0.1"), PortNumber.portNumber(4)); // h1 via s5 and s3 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.2"), PortNumber.portNumber(4)); // h2 via s5 and s3 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.5"), PortNumber.portNumber(4)); // h5 via s5 and s3 and s1
        routingTable.put(Ip4Address.valueOf("10.0.0.3"), PortNumber.portNumber(4)); // h3 via s5 and s3
        routingTable.put(Ip4Address.valueOf("10.0.0.4"), PortNumber.portNumber(4)); // h4 via s5 and s3
        routingTable.put(Ip4Address.valueOf("10.0.0.7"), PortNumber.portNumber(4)); // h7 via s5 and s3 and s4
    }

    private class ReactivePacketProcessor implements PacketProcessor {
        @Override
        public void process(PacketContext context) {
            Ethernet eth = context.inPacket().parsed();
            if (eth == null) {
                log.warn("Parsed Ethernet frame is null");
                return;
            }

            if (context.isHandled()) {
                return;
            }

            if (eth.getEtherType() == Ethernet.TYPE_IPV4) {
                IPv4 ipv4 = (IPv4) eth.getPayload();
                Ip4Address dstIp = Ip4Address.valueOf(ipv4.getDestinationAddress());
                log.info("IPv4 packet received with destination IP: {}", dstIp);
                forwardPacket(context, dstIp);
            }
        }
    }

    private void forwardPacket(PacketContext context, Ip4Address dstIp) {
        ConnectPoint srcPoint = context.inPacket().receivedFrom();

        // Lookup the destination IP in the routing table
        PortNumber outputPort = routingTable.get(dstIp);

        if (outputPort == null) {
            log.warn("No route found for destination IP: {}", dstIp);
            return;
        }

        log.info("Forwarding packet from: {} to output port: {}", srcPoint, outputPort);

        try {
            FlowRule rule = DefaultFlowRule.builder()
                    .forDevice(srcPoint.deviceId())
                    .withSelector(DefaultTrafficSelector.builder()
                            .matchEthType(Ethernet.TYPE_IPV4)
                            .matchIPDst(dstIp.toIpPrefix())
                            .build())
                    .withTreatment(DefaultTrafficTreatment.builder()
                            .setOutput(outputPort)
                            .build())
                    .withPriority(50000)
                    .fromApp(appId)
                    .makeTemporary(10)
                    .build();

            log.info("Applying flow rule: {}", rule);
            flowRuleService.applyFlowRules(rule);
        } catch (Exception e) {
            log.error("Exception while building flow rule", e);
        }
    }
}
