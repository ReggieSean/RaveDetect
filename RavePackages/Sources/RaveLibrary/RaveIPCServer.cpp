//
//  RaveIPCServer.cpp
//  
//
//  Created by SeanHuang on 09/13/24.
//

#include "RaveLibrary.h"

//The steps involved in establishing a socket on the server side are as follows:
//
//Create a socket with the socket() system call
//Bind the socket to an address using the bind() system call. For a server socket on the Internet, an address consists of a port number on the host machine.
//Listen for connections with the listen() system call
//Accept a connection with the accept() system call. This call typically blocks until a client connects with the server.
//Send and receive data

void RaveIPCServer::create_socket(){}
void RaveIPCServer::bind_socket_to_address(){}
void RaveIPCServer::listen(){
//    serverSocket = socket(AF_UNIX , SOCK_STREAM, 0);
//        if (serverSocket == -1) {
//            std::cerr << "Failed to create socket" << std::endl;
//            return;
//        }
//
//        sockaddr_in serverAddr{};
//        serverAddr.sin_family = AF_INET;
//        serverAddr.sin_addr.s_addr = INADDR_ANY;
//        serverAddr.sin_port = htons(port);
//
//        if (bind(serverSocket, (struct sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
//            std::cerr << "Bind failed" << std::endl;
//            return;
//        }
//
//        if (listen(serverSocket, 5) < 0) {
//            std::cerr << "Listen failed" << std::endl;
//            return;
//        }
//
//        running = true;
//        std::cout << "Server started on port " << port << std::endl;
//
//        // Accept clients in a loop
//        while (running) {
//            int clientSocket = accept(serverSocket, nullptr, nullptr);
//            if (clientSocket >= 0) {
//                std::thread(&SensorServer::handleClient, this, clientSocket).detach();
//            }
    
}
void RaveIPCServer::accept(){}
void RaveIPCServer::send(){}
void RaveIPCServer::receive(){}
