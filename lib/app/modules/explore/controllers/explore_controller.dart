import 'package:get/get.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../data/services/streaming_service.dart';

class ExploreController extends GetxController {
  final StreamingService _streamingService = Get.put(StreamingService());

  final RxString selectedCategory = "All".obs;
  final RxList<LiveStreamModel> streams = <LiveStreamModel>[].obs;
  final RxBool isLoading = false.obs;

  final List<String> categories = ["All", "Just fun", "Fitness", "Health"];

  @override
  void onInit() {
    super.onInit();
    fetchStreams();
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchStreams();
  }

  Future<void> fetchStreams() async {
    isLoading.value = true;
    try {
      List<LiveStreamModel> fetchedStreams;
      if (selectedCategory.value == "All") {
        fetchedStreams = await _streamingService.getAllLiveStreams();
      } else {
        // Map UI category to API parameter logic if needed (e.g. lowercase)
        // Adjusting casing as per requirement: "fun", "fitness", "health"
        String apiCategory = selectedCategory.value;
        if (apiCategory == "Just fun") apiCategory = "fun";
        
        fetchedStreams = await _streamingService.getActiveStreamsByCategory(apiCategory.toLowerCase());
      }
      streams.assignAll(fetchedStreams);
    } catch (e) {
      print("Error in ExploreController: $e");
      // Handle error cleanly or show empty state
      streams.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
