import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import '../controllers/live_streaming_controller.dart';

class LiveStreamingView extends GetView<LiveStreamingController> {
  const LiveStreamingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for video
      body: Stack(
        children: [
          // 1. Video Layer
          Positioned.fill(
            child: Obx(() {
              if (!controller.isConnected.value) {
                if (controller.errorMessage.isNotEmpty) {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    ));
                }
                return const Center(child: CircularProgressIndicator());
              }

              // Logic: specific to Bigo-like apps. 
              // Usually there is 1 MAIN HOST video covering the screen.
              
              VideoTrack? mainTrack;
              
              if (controller.isHost) {
                 mainTrack = controller.localVideoTrack.value;
              } else if (controller.remoteVideoTracks.isNotEmpty) {
                 // Usually the first remote track is the host
                 mainTrack = controller.remoteVideoTracks.first;
              }

              if (mainTrack == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       // If host, show profile pic or "Camera Off"
                       // If viewer, show "Waiting for host..."
                       if (controller.isHost)
                         Column(
                           children: [
                             CircleAvatar(
                               radius: 50,
                               backgroundColor: Colors.grey.shade800,
                               backgroundImage: controller.currentUser.value?.profileImage != null 
                                 ? NetworkImage(controller.currentUser.value!.profileImage!) 
                                 : null,
                               child: const Icon(Icons.videocam_off, size: 40, color: Colors.white),
                             ),
                             const SizedBox(height: 10),
                             const Text("Camera Off", style: TextStyle(color: Colors.white)),
                           ],
                         )
                       else
                         const Text(
                          "Waiting for host...", 
                          style: TextStyle(color: Colors.white)
                        )
                    ],
                  )
                );
              }

              return VideoTrackRenderer(
                mainTrack,
                fit: VideoViewFit.cover,
              );
            }),
          ),

          // 2. Overlay Layer (Chat, Hearts, Controls)
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // Top Bar (Close button, Host info)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black45, 
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CircleAvatar(
                                      radius: 12, 
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person, color: Colors.white, size: 16),   //// profile image
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller.streamTitle.isNotEmpty ? controller.streamTitle : controller.roomName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                                // if (controller.streamCategory.isNotEmpty)
                                //   Padding(
                                //     padding: const EdgeInsets.only(left: 32.0),
                                //     child: Text(
                                //       controller.streamCategory,
                                //       style: const TextStyle(color: Colors.white70, fontSize: 10),
                                //     ),
                                //   ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: GestureDetector(
                            onTap: (){
                              controller.leaveRoom();
                            },
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: controller.leaveRoom,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Comments Area
                  Expanded(
                    flex: 1, // Take bottom part
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Messages List
                          Expanded(
                            child: Obx(() => ListView.builder(
                              reverse: true, // Show new messages at bottom (requires reversing list or reversed order)
                              // Actually standard ListView scrolls down.
                              // Let's keep it simple: items at bottom.
                              itemCount: controller.comments.length,
                              itemBuilder: (context, index) {
                                // Show latest at bottom
                                final comment = controller.comments[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  // decoration: BoxDecoration(
                                  //   color: Colors.black38,
                                  //   borderRadius: BorderRadius.circular(8)
                                  // ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.grey,
                                        backgroundImage: comment['image'] != null && comment['image'].toString().isNotEmpty
                                            ? NetworkImage(comment['image'])
                                            : null,
                                        child: comment['image'] == null || comment['image'].toString().isEmpty
                                            ? const Icon(Icons.person, size: 14, color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "${comment['name']}: ",
                                                style: TextStyle(
                                                  color: comment['is_host'] == true ? Colors.redAccent : Colors.yellowAccent, 
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14
                                                )
                                              ),
                                              TextSpan(
                                                text: comment['message'],
                                                style: TextStyle(
                                                  color: comment['is_gift'] == true ? Colors.amber : Colors.white, 
                                                  fontSize: 14
                                                )
                                              ),
                                            ]
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )),
                          ),
                          
                          // Input & Actions
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller.commentController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "Say hi...",
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    filled: true,
                                    fillColor: Colors.black45,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send, color: Colors.blueAccent),
                                      onPressed: controller.sendComment,
                                    )
                                  ),
                                  onSubmitted: (_) => controller.sendComment(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              if (!controller.isHost) ...[
                                // Gift Button
                                GestureDetector(
                                  onTap: () => _showGiftSheet(context),
                                  child: const CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.purpleAccent,
                                    child: Icon(Icons.card_giftcard, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],

                              // Like Button
                              GestureDetector(
                                onTap: controller.sendLike,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.pinkAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.favorite, color: Colors.white),
                                      Obx(() => Text(
                                        "${controller.totalLikes}", 
                                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                                      ))
                                    ],
                                  )
                                )
                              ),
                            ],
                          ),

                          if (controller.isHost) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(() => _buildControlBtn(
                                      icon: controller.isCameraEnabled.value ? Icons.videocam : Icons.videocam_off,
                                      onTap: controller.toggleCamera,
                                      isActive: controller.isCameraEnabled.value
                                    )),
                                    const SizedBox(width: 20),
                                    Obx(() => _buildControlBtn(
                                      icon: controller.isMicEnabled.value ? Icons.mic : Icons.mic_off,
                                      onTap: controller.toggleMic,
                                      isActive: controller.isMicEnabled.value
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGiftSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: [
              const Text("Send a Gift", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    _buildGiftItem("Rose", "🌹", 10),
                    _buildGiftItem("Heart", "❤️", 50),
                    _buildGiftItem("Diamond", "💎", 100),
                    _buildGiftItem("Car", "🏎️", 500),
                    _buildGiftItem("Rocket", "🚀", 1000),
                    _buildGiftItem("Crown", "👑", 5000),
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildGiftItem(String name, String icon, double price) {
    return InkWell(
      onTap: () => controller.sendGift(price),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text("$price Coins", style: const TextStyle(color: Colors.amber, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBtn({required IconData icon, required VoidCallback onTap, required bool isActive}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.black : Colors.red, size: 24),
      ),
    );
  }
}
