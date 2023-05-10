import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'httpInterceptor.dart';

class CardSwipe extends StatefulWidget {
  const CardSwipe({Key? key}) : super(key: key);

  @override
  State<CardSwipe> createState() => _CardSwipeState();
}

class _CardSwipeState extends State<CardSwipe> {
  final AppinioSwiperController controller = AppinioSwiperController();
  final Dio dio;
  List contents = [];
  List images = [];
  List<Card> cardList = [];
  final _storage = const FlutterSecureStorage();
  int page = 0;

  _CardSwipeState() : dio = Dio()..interceptors.add(HttpInterceptor());

  Future<void> _getList() async {
    try {
      Map body;
      Response res = await dio.get(
        (dotenv.env['MEMBER_RECOMMEND']! +
            "?page=" +
            page.toString() +
            "&size=5"),
      );
      if (res.statusCode == 200) {
        setState(() {
          contents += res.data['content'];
          page++;
        });
        print(contents[0]['post']['filenames']);
      }
    } catch (e) {
      print(e);
    }
  }

  void _swipe(int index, AppinioSwiperDirection direction) async {
    int id = contents[index]["id"];
    if (direction == AppinioSwiperDirection.left) {
      Fluttertoast.showToast(
        msg: "싫어요",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } else if (direction == AppinioSwiperDirection.right) {
      Response res = await dio.post(dotenv.env["MEMBER_LIKE"]! + id.toString());
      if (res.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "좋아요",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  @override
  void initState() {
    _getList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: AppinioSwiper(
          onEnd: () async {
            await _getList();
          },
          onSwipe: _swipe,
          cardsCount: contents.length,
          cardsBuilder: (BuildContext context, int index) {
            if (index == contents.length - 2) {
              _getList();
            }
            return Card(
              data: contents[index],
            );
          },
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  const Card({Key? key, required this.data}) : super(key: key);
  final Map data;

  @override
  Widget build(BuildContext context) {
    return ImageSwipe(key: UniqueKey(), filenames: data['post']['filenames']);
  }
}

//카드 한 장 안에 여러 장의 이미지를 탭 하면 넘기는 기능
class ImageSwipe extends StatefulWidget {
  const ImageSwipe({Key? key, required this.filenames}) : super(key: key);
  final List filenames;

  @override
  State<ImageSwipe> createState() => _ImageSwipeState(filenames);
}

class _ImageSwipeState extends State<ImageSwipe> {
  num _currentIndex = 0;
  List filenames;

  _ImageSwipeState(this.filenames);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTapUp: (details) {
            double screenWidth = MediaQuery.of(context).size.width;
            double tapPosition = details.globalPosition.dx;
            if (tapPosition < screenWidth / 2) {
              setState(() {
                _currentIndex = (_currentIndex - 1) % filenames.length;
              });
            } else if (tapPosition > screenWidth / 2) {
              setState(() {
                _currentIndex = (_currentIndex + 1) % filenames.length;
              });
            }
          },
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FadeInImage(
                placeholder: AssetImage('assets/Loading_icon.gif'),
                // 로딩 중일 때 표시할 이미지
                image: NetworkImage(
                    dotenv.env['IMAGE_URL']! + filenames[_currentIndex as int]),
                // 로드할 이미지
                fit: BoxFit.cover,
              )),
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(filenames.length, (index) {
              return Opacity(
                opacity: index == _currentIndex ? 1.0 : 0.5,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75 / 3,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    color: index == _currentIndex ? Colors.white : Colors.grey,
                  ),
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}
