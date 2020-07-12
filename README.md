# Goodjob package for flutter

A new Flutter package.

## Getting Started

This project is a starting point for a Dart
[package](https://flutter.dev/developing-packages/),
a library module containing code that can be shared easily across
multiple Flutter or Dart projects.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

# 账号注册及申请

1.登陆 [https://goodjob.ai/](https://goodjob.ai/) 申请成为开发者

2.面板栏选择创建新项目

![图片](https://uploader.shimo.im/f/vSPBAoU7br7HdPwT.png!thumbnail)

3.个人中心查看生成的 apiKey 和 apiSecret.

# SDK-Flutter集成

## 集成

1. 通过 GitHub 下载依赖 [https://github.com/orth/goodjob_flutter](https://github.com/orth/goodjob_flutter)，手动导入项目
2. dependencies 方式引入暂不支持
## 使用

1. 初始化 sdk 
```plain
GoodJobBusiness _business = GoodJobBusiness.getInstance();
_business.initSDK(
    apiKey: "goodjob_api_key",
    apiSecret: "goodjob_api_secret",
    id: '10133');
    
```
1. 获取翻译结果（keyName需要和 goodjob 配置的名称一一对应，如需修改请在后台操作），默认中文
```plain
var res = await _business.interpret(keyName);
```
1. 切换语言
```plain
_business.switchLanguage(language: lang);
```
1. 获取已添加语言列表
```plain
_business.getLanguageList();
```
## 其它

如果想控制全局状态的变更，建议本地手动导入 provider

```plain
dependencies:
  provider: ^4.0.5
```
文档provider官方文档
[https://pub.dev/packages/provider](https://pub.dev/packages/provider)

example以4.0.5为例：

1. 定义 Counter 文件

```plain
class Counter with ChangeNotifier,DiagnosticableTreeMixin{
  String _key10 = "";
  String get key10 => _key10;
  void initCounter({String lang}) async {
    GoodJobBusiness _business = GoodJobBusiness.getInstance();
    if (lang != null) {
      _business.switchLanguage(language: lang);
    }
    _key10 = await _business.interpret("key10");
    notifyListeners();
  }  
}
```
2. 修改 main 中 App 入口
```plain
void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Counter()),
    ],
    child: MyApp(),
  ));
}
```
3. 使用

```plain
Text('${Provider.of<Counter>(context).key10}')
```
