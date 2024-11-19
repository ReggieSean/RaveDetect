//
//  RaveIPC.cpp
//  
//
//  Created by SeanHuang on 09/11/24.
//
//https://www.swift.org/documentation/cxx-interop/project-build-setup/#mixing-swift-and-c-using-swift-package-manager
//test calling these apis from Swift
#include "RaveLibrary.h"


void RaveIPCClient::create_socket(){
    struct sockaddr_un addr;
    int i;
    int ret;
    int data_socket;
    char buffer[BUFFER_SIZE];
    
}
void RaveIPCClient::connect_socket(){
}

//function that swift uses
void RaveIPCClient::send_buffer(){
}
