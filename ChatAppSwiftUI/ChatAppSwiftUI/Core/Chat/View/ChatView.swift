//
//  ChatView.swift
//  ChatAppSwiftUI
//
//  Created by Phan Tam Nhu on 20/5/24.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    private var selectedUser: User
    
    init(selectedUser: User) {
        self.selectedUser = selectedUser
        self._viewModel = StateObject(wrappedValue: ChatViewModel(chatPartner: selectedUser))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(viewModel.messageGroups, id: \.self) { group in
                            Section {
                                ForEach(group.messages) { message in
                                    ChatMessageCell(isFromCurrentUser: message.isFromCurrentUser, message: message)
                                }
                            } header: {
                                Capsule()
                                    .fill(Color(.systemGray5))
                                    .frame(width: 120, height: 44)
                                    .overlay {
                                        Text(group.date.chatTimestampString())
                                    }
                            }
                        }
                        HStack { Spacer() }
                            .id("bottom")
                    }
                    .onReceive(viewModel.$count) { _ in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo("bottom", anchor: .top)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                ZStack {
                    EmojiTextField(text: $viewModel.messageText, isEmoji: $viewModel.isEmoji, placeholder: "Message...")
                        .padding(.vertical, 12)
                        .padding(.leading, 44)
                        .padding(.trailing, 60)
                        .background(Color(.systemGroupedBackground))
                        .clipShape(Capsule())
                        .frame(height: 25)
                    HStack {
                        Button {
                            viewModel.isEmoji.toggle()
                        } label: {
                            Image(systemName: "face.smiling")
                        }

                        Spacer()
                        
                        Button {
                            viewModel.showVideoPicker.toggle()
                        } label: {
                            Image(systemName: "paperclip")
                        }
                        
                        Button {
                            viewModel.showPhotoPicker.toggle()
                        } label: {
                            Image(systemName: "camera.fill")
                        }
                    }
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                }
                Button(action: {
                    if viewModel.messageText != "" {
                        viewModel.sendMessage(chatPartner: selectedUser, isImage: false, isVideo: false, isAudio: false)
                    } else {
                        if !viewModel.isRecording {
                            viewModel.startRecording()
                        } else {
                            Task { try await viewModel.finishRecording() }
                        }
                    }
                }, label: {
                    if !viewModel.isRecording {
                        Image(systemName: viewModel.messageText == "" ? "mic.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.darkGray))
                    } else {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(.darkGray))
                    }
                })
            }
            .padding()
        }
        .background{
            Image("background_image")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(isPresented: $viewModel.showPhotoPicker,
                      selection: $viewModel.selectedImage,
                      matching: .any(of: [.images, .not(.videos)]))
        .photosPicker(isPresented: $viewModel.showVideoPicker,
                      selection: $viewModel.selectedVideo,
                      matching: .any(of: [.videos, .not(.images)]))
        .toolbar(viewModel.tabbarVisibility, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button(action: {
                        viewModel.tabbarVisibility = .visible
                        dismiss()
                    }, label: {
                        Image(systemName: "arrow.backward")
                    })
                    CircularProfileImageView(size: .xsmall, user: selectedUser)
                    Text(selectedUser.fullName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 24) {
                    Image(systemName: "video.fill")
                    Image(systemName: "phone.fill")
                    Image(systemName: "ellipsis")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    ChatView(selectedUser: User.MOCK_USER)
}
