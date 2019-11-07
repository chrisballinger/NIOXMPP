//
//  Bootstrap.swift
//  NIOXMPP
//
//  Created by Chris Ballinger on 11/6/19.
//  Copyright © 2019 ChatSecure. All rights reserved.
//

import Foundation
import NIO
import NIOExtras
import NIOTransportServices
import NIOTLS
import NIOSSL

// MARK: - NIO/NIOTS handling

/// This protocol is intended as a layer of abstraction over `ClientBootstrap` and
/// `NIOTSConnectionBootstrap`. We only need a `connect` method since configuration
/// is done on the concrete type.
protocol ClientBootstrapProtocol {
    func connect(host: String, port: Int) -> EventLoopFuture<Channel>
}

extension ClientBootstrap: ClientBootstrapProtocol {}

#if canImport(Network)
@available(OSX 10.14, iOS 12.0, tvOS 12.0, watchOS 6.0, *)
extension NIOTSConnectionBootstrap: ClientBootstrapProtocol {}
#endif

func makeNIOSMTPHandlers(communicationHandler: @escaping (String) -> Void,
                         email: Email,
                         emailSentPromise: EventLoopPromise<Void>) -> [ChannelHandler] {
    return [
        PrintEverythingHandler(handler: communicationHandler),
        ByteToMessageHandler(LineBasedFrameDecoder()),
        SMTPResponseDecoder(),
        MessageToByteHandler(SMTPRequestEncoder()),
        SendEmailHandler(configuration: Configuration.shared.serverConfig,
                         email: email,
                         allDonePromise: emailSentPromise)
    ]
}

@available(OSX 10.14, iOS 12.0, tvOS 12.0, watchOS 6.0, *)
func configureNIOTSBootstrap(group: NIOTSEventLoopGroup,
                             email: Email,
                             emailSentPromise: EventLoopPromise<Void>,
                             communicationHandler: @escaping (String) -> Void) -> ClientBootstrapProtocol {
    
    let bootstrap = NIOTSConnectionBootstrap(group: group).channelInitializer { channel in
        
        let handlers: [ChannelHandler] = makeNIOSMTPHandlers(communicationHandler: communicationHandler, email: email, emailSentPromise: emailSentPromise)
        
        return channel.pipeline.addHandlers(handlers, position: .last)
    }
    
    switch Configuration.shared.serverConfig.tlsConfiguration {
    case .regularTLS:
        return bootstrap.tlsOptions(.init())
    case .startTLS, .unsafeNoTLS:
        return bootstrap
    }
}

func configureBootstrap(group: EventLoopGroup,
                        email: Email,
                        emailSentPromise: EventLoopPromise<Void>,
                        communicationHandler: @escaping (String) -> Void) -> ClientBootstrapProtocol {
    return ClientBootstrap(group: group).channelInitializer { channel in
        
        var handlers: [ChannelHandler] = makeNIOSMTPHandlers(communicationHandler: communicationHandler, email: email, emailSentPromise: emailSentPromise)
        
        switch Configuration.shared.serverConfig.tlsConfiguration {
        case .regularTLS:
            do {
                let sslContext = try NIOSSLContext(configuration: .forClient())
                let sslHandler = try NIOSSLClientHandler(context: sslContext,
                                                         serverHostname: Configuration.shared.serverConfig.hostname)
                handlers.insert(sslHandler, at: 0)
            } catch {
                return channel.eventLoop.makeFailedFuture(error)
            }
        case .startTLS, .unsafeNoTLS:
            () // no TLS added to start with
        }
        
        return channel.pipeline.addHandlers(handlers, position: .last)
    }
}

/// Network implementation and by extension which version of NIO to use.
enum NetworkImplementation {
    /// POSIX sockets and NIO.
    case posix
    
    /// NIOTransportServices (and Network.framework).
    case transportServices
    
    /// Return the best implementation available for this platform, that is NIOTransportServices
    /// when it is available or POSIX and NIO otherwise.
    static var best: NetworkImplementation {
        if #available(OSX 10.14, iOS 12.0, tvOS 12.0, watchOS 6.0, *) {
            return .transportServices
        } else {
            return .posix
        }
    }
}

/// Makes an appropriate `EventLoopGroup` based on the given implementation.
///
/// For `.posix` this is a `MultiThreadedEventLoopGroup`, for `.networkFramework` it is a
/// `NIOTSEventLoopGroup`.
///
/// - Parameter implementation: The network implementation to use.
func makeEventLoopGroup(loopCount: Int, implementation: NetworkImplementation) -> EventLoopGroup {
    switch implementation {
    case .transportServices:
        guard #available(OSX 10.14, iOS 12.0, tvOS 12.0, watchOS 6.0, *) else {
            // This is gated by the availability of `.networkFramework` so should never happen.
            fatalError(".networkFramework is being used on an unsupported platform")
        }
        return NIOTSEventLoopGroup(loopCount: loopCount, defaultQoS: .utility)
    case .posix:
        return MultiThreadedEventLoopGroup(numberOfThreads: loopCount)
    }
}
