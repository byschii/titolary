
import 'package:firebase_admob/firebase_admob.dart';

// justs return an id, given and index
// so that i don't have to remember every thing
class AdsIdsService{
  static List<String> banners = [
    BannerAd.testAdUnitId,
    'ca-app-pub-2360554820743757/7459336785',
    'ca-app-pub-2360554820743757/1403954503',
  ];

  static String getBanner(int index){
    return banners[index];
  }

}