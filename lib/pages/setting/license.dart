import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class License extends StatefulWidget {
  const License({Key key}) : super(key: key);

  @override
  _LicenseState createState() => _LicenseState();
}

class _LicenseState extends State<License> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("${Util.appName}用户协议"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          Center(
            child: Text(
              "《${Util.appName}用户协议》",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Text('''
概述

本用户协议（以下简称“本协议”）适用于青岛阿派派软件有限公司运营和管理（以下简称“我们”，“本公司”）旗下的《${Util.appName}软件》（以下简称“本产品”）。本协议是您（个人或单一实体）与本公司之间就使用本产品达成的具有法律约束力的法律协议。该法律协议包括但不限于本页面的全部条款与《隐私政策》。

请您在使用本产品之前仔细阅读下列条款。您下载、安装或使用产本品或者单击“ 我同意”表明您已经阅读本协议并充分理解、遵守本协议所有条款，包括涉及免除或者限制本公司责任的免责条款、用户权利限制条款、约定争议解决方式等，这些条款均用粗体字标注。如果您不同意本协议的全部或部分内容，请不要下载、安装和使用本产品。


1. 权利声明

1.1 知识产权。

本公司拥有“本产品”的所有权和知识产权等全部权利。本产品受中国及其他国家的知识产权法、国际知识产权公约（包括但不限于著作权法、商标法、专利法等）的保护。所有未授予您的权利均被本公司保留，您不可以从本产品上移除本公司的版权标记或其他权利声明。

“群晖”商标为群晖科技股份有限公司所有，本软件仅通过其NAS设备提供的API接口对设备进行访问，并未进行商业用途！

DSM 专用于 Synology 产品的操作系统，由 Synology Inc.拥有。DSM 提供综合存储解决方案、灵活的备份策略、随手成为更加智能的多媒体管理（以及更多！）。

1.2 软件所有权保留。

您确定不享有本软件的所有权，本软件未被出售给用户，本公司保留本软件的所有权。


2. 授权许可

2.1 授权许可。

本公司授予您一项非排他的、不可转让的、非商业性的、可撤销的许可，以下载、安装、备份和使用本产品。本公司授予您仅出于个人非商业目在移动设备上使用本产品，如果您希望将本产品用于其他非本公司授权的目的或其他商业目的，您必须另行取得本公司的单独书面许可。

3. 用户行为

3.1 数据存储。

除安卓版本的检查更新及安装统计功能外，其他所有功能与数据存储均来自您个人的群晖NAS硬件设备，在使用过程中，您将承担因下述行为而产生的全部法律责任，本公司不对您的下述行为承担任何责任：

破坏宪法所确定的基本原则的；

危害国家安全、泄露国家秘密、颠覆国家政权、破坏国家统一的；

损害国家荣誉和利益的；

煽动民族仇恨、民族歧视，破坏民族团结的；

破坏国家宗教政策，宣扬邪教和封建迷信的；

散布谣言，扰乱社会秩序，破坏社会稳定的；

散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；

侮辱或者诽谤他人，侵害他人合法权益的；

含有法律、行政法规禁止的其他内容的。

3.2 费用。

我们的产品或服务都是是免费的，但不包括个人上网或第三方（包括但不限于电信或移动通讯提供商）收取的通讯费、信息费等相关费用。

4. 功能的调整、改进与升级

我们可能对产品进行不时地调整、改进和增减，甚至下线我们部分产品，以不断适应我们的运营需要。任何本产品的更新版本或未来版本或者其他变更同样受到本协议约束。


5. 无担保声明

5.1 本公司在发布本产品之前，已尽可能对产品进行了详尽的技术测试和功能测试，但鉴于电子设备、操作系统、网络环境的复杂性，本公司不能保证本产品会兼容所有用户的电子设备，也无法保证用户在使用本产品过程中能够持续不出现任何技术故障。

5.2 在法律允许的最大限度内，本公司无法对产品或服务做任何明示、暗示和强制的担保，包括但不限于软件的兼容性；产品一定满足您的需求或期望；或产品将不间断的、及时的、安全的、或无错误的运行。

5.3  由于网络环境的自由与开放特征，我们的产品或服可能会被第三方擅自修改、破解发布于互联网，建议用户从本公司的官方应用渠道，如官网、本公司已申请认证的第三方应用商店下载、安装我们的产品，我们不会对任何非官方版本承担任何责任。
          '''),
        ],
      ),
    );
  }
}
