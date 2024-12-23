import 'package:dsm_helper/pages/control_panel/power/add_power_task.dart';
import 'package:dsm_helper/themes/app_theme.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/util/neu_picker.dart';
import 'package:dsm_helper/widgets/bubble_tab_indicator.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:dsm_helper/util/function.dart';

class Power extends StatefulWidget {
  @override
  _PowerState createState() => _PowerState();
}

class _PowerState extends State<Power> with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool loading = true;
  bool enableZram = false;
  Map powerRecovery;
  Map beepControl;
  Map fanSpeed;
  Map hibernation;
  Map ups;
  Map led;
  List powerTasks = [];

  List dataList = [
    {
      "value": 0,
      "title": "无",
    },
    {
      "value": 10,
      "title": "10分钟",
    },
    {
      "value": 15,
      "title": "15分钟",
    },
    {
      "value": 20,
      "title": "20分钟",
    },
    {
      "value": 30,
      "title": "30分钟",
    },
    {
      "value": 60,
      "title": "1小时",
    },
    {
      "value": 120,
      "title": "2小时",
    },
    {
      "value": 180,
      "title": "3小时",
    },
    {
      "value": 240,
      "title": "4小时",
    },
    {
      "value": 300,
      "title": "5小时",
    },
  ];
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    getData();
    super.initState();
  }

  getData() async {
    Api.powerStatus().then((res) {
      if (res['success']) {
        setState(() {
          loading = false;
        });
        List result = res['data']['result'];
        result.forEach((item) {
          if (item['success'] == true) {
            switch (item['api']) {
              case "SYNO.Core.Hardware.ZRAM":
                setState(() {
                  enableZram = item['data']['enable_zram'];
                });
                break;
              case "SYNO.Core.Hardware.PowerRecovery":
                setState(() {
                  powerRecovery = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.BeepControl":
                setState(() {
                  beepControl = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.FanSpeed":
                setState(() {
                  fanSpeed = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.Led.Brightness":
                setState(() {
                  led = item['data'];
                });
                break;
              case "SYNO.Core.ExternalDevice.UPS":
                setState(() {
                  ups = item['data'];
                });
                break;
              case "SYNO.Core.Hardware.PowerSchedule":
                setState(() {
                  List powerOnTasks = item['data']['poweron_tasks'];
                  List powerOffTasks = item['data']['poweroff_tasks'];
                  powerTasks = powerOnTasks.map((e) {
                        e['type'] = "power_on";
                        return e;
                      }).toList() +
                      powerOffTasks.map((e) {
                        e['type'] = "power_off";
                        return e;
                      }).toList();
                  powerTasks.sort((a, b) {
                    if (a['hour'] > b['hour']) {
                      return 1;
                    } else if (a['hour'] == b['hour']) {
                      if (a['min'] > b['min']) {
                        return 1;
                      } else if (a['min'] < b['min']) {
                        return -1;
                      } else {
                        return 0;
                      }
                    } else {
                      return -1;
                    }
                  });
                });
                break;
              case "SYNO.Core.Hardware.Hibernation":
                setState(() {
                  hibernation = item['data'];
                });
                break;
            }
          }
        });
      }
    });
  }

  Map weekday = {
    "0": "周日",
    "1": "周一",
    "2": "周二",
    "3": "周三",
    "4": "周四",
    "5": "周五",
    "6": "周六",
  };
  Widget _buildPowerTaskItem(task) {
    String weekdays = "";
    if (task['weekdays'] == "0,1,2,3,4,5,6") {
      weekdays = "每天";
    } else if (task['weekdays'] == "1,2,3,4,5") {
      weekdays = "平日";
    } else if (task['weekdays'] == "0,6") {
      weekdays = "假日";
    } else {
      List days = task['weekdays'].split(",");
      weekdays = days.map((e) => weekday[e]).join(",");
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          task['enabled'] = !task['enabled'];
        });
      },
      child: NeuCard(
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        bevel: 10,
        curveType: task['enabled'] ? CurveType.emboss : CurveType.flat,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: task['enabled']
                    ? Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Color(0xffff9813),
                        size: 22,
                      )
                    : null,
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("${task['hour'].toString().padLeft(2, "0")}:${task['min'].toString().padLeft(2, "0")}"),
                        SizedBox(
                          width: 5,
                        ),
                        Label(task['type'] == "power_on" ? "开机" : "关机", task['type'] == "power_on" ? Colors.green : Colors.orangeAccent),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "$weekdays",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  NeuButton(
                    onPressed: () {
                      setState(() {
                        powerTasks.remove(task);
                      });
                    },
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(5),
                    bevel: 5,
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  NeuButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(
                              builder: (context) {
                                return AddPowerTask(
                                  "编辑计划管理",
                                  task: task,
                                );
                              },
                              settings: RouteSettings(name: "edit_power_task")))
                          .then((value) {
                        if (value != null) {
                          for (var item in powerTasks) {
                            if (item != task && item['hour'] == value['hour'] && item['min'] == value['min']) {
                              Util.toast("无效或重复规则");
                              Util.vibrate(FeedbackType.warning);
                              return;
                            }
                          }
                          setState(() {
                            task = value;
                          });
                        }
                      });
                    },
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(5),
                    bevel: 5,
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("硬件和电源"),
      ),
      body: loading
          ? Center(
              child: NeuCard(
                padding: EdgeInsets.all(50),
                curveType: CurveType.flat,
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                bevel: 20,
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          : Column(
              children: [
                NeuCard(
                  width: double.infinity,
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  curveType: CurveType.flat,
                  bevel: 10,
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicator: BubbleTabIndicator(
                      indicatorColor: Theme.of(context).scaffoldBackgroundColor,
                      shadowColor: Util.getAdjustColor(Theme.of(context).scaffoldBackgroundColor, -20),
                    ),
                    tabs: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("常规"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("开关机计划管理"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("硬盘休眠"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: Text("不断电系统"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "内存压缩",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  enableZram = !enableZram;
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: enableZram ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Text("启用内存压缩可提高系统响应性能"),
                                                    Spacer(),
                                                    if (enableZram)
                                                      Icon(
                                                        CupertinoIcons.checkmark_alt,
                                                        color: Color(0xffff9813),
                                                        size: 22,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "电源自动恢复",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  powerRecovery['rc_power_config'] = !powerRecovery['rc_power_config'];
                                                });
                                              },
                                              child: NeuCard(
                                                decoration: NeumorphicDecoration(
                                                  color: Theme.of(context).scaffoldBackgroundColor,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                padding: EdgeInsets.all(10),
                                                bevel: 10,
                                                curveType: powerRecovery['rc_power_config'] ? CurveType.emboss : CurveType.flat,
                                                child: Row(
                                                  children: [
                                                    Text("修复电源问题后自动重新启动"),
                                                    Spacer(),
                                                    if (powerRecovery['rc_power_config'])
                                                      Icon(
                                                        CupertinoIcons.checkmark_alt,
                                                        color: Color(0xffff9813),
                                                        size: 22,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (powerRecovery['internal_lan_num'] != null)
                                              for (int i = 1; i <= powerRecovery['internal_lan_num']; i++)
                                                if (powerRecovery['wol$i'] != null) ...[
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        powerRecovery['wol$i'] = !powerRecovery['wol$i'];
                                                      });
                                                    },
                                                    child: NeuCard(
                                                      decoration: NeumorphicDecoration(
                                                        color: Theme.of(context).scaffoldBackgroundColor,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: EdgeInsets.all(10),
                                                      bevel: 10,
                                                      curveType: powerRecovery['wol$i'] ? CurveType.emboss : CurveType.flat,
                                                      child: Row(
                                                        children: [
                                                          Text("启用局域网 $i 的局域网唤醒"),
                                                          Spacer(),
                                                          if (powerRecovery['wol$i'])
                                                            Icon(
                                                              CupertinoIcons.checkmark_alt,
                                                              color: Color(0xffff9813),
                                                              size: 22,
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "哔声控制",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (beepControl['support_fan_fail'] != null && beepControl['support_fan_fail']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['fan_fail'] = !beepControl['fan_fail'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['fan_fail'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("冷却风扇故障"),
                                                      Spacer(),
                                                      if (beepControl['fan_fail'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_volume_crash'] != null && beepControl['support_volume_crash']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['volume_crash'] = !beepControl['volume_crash'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['volume_crash'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("存储空间降级或毁损"),
                                                      Spacer(),
                                                      if (beepControl['volume_crash'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_volume_or_cache_crash'] != null && beepControl['support_volume_or_cache_crash']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['support_volume_or_cache_crash'] = !beepControl['support_volume_or_cache_crash'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['support_volume_or_cache_crash'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("存储空间或 SSD 缓存异常"),
                                                      Spacer(),
                                                      if (beepControl['support_volume_or_cache_crash'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_ssd_cache_crash'] != null && beepControl['support_ssd_cache_crash']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['ssd_cache_crash'] = !beepControl['ssd_cache_crash'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['ssd_cache_crash'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("SSD 缓存异常"),
                                                      Spacer(),
                                                      if (beepControl['ssd_cache_crash'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_poweron_beep'] != null && beepControl['support_poweron_beep']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['poweron_beep'] = !beepControl['poweron_beep'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['poweron_beep'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("系统开机"),
                                                      Spacer(),
                                                      if (beepControl['poweron_beep'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_poweroff_beep'] != null && beepControl['support_poweroff_beep']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['poweroff_beep'] = !beepControl['poweroff_beep'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['poweroff_beep'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("按下电源按钮后系统关机"),
                                                      Spacer(),
                                                      if (beepControl['poweroff_beep'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_redundant_power_fail'] != null && beepControl['support_redundant_power_fail']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['redundant_power_fail'] = !beepControl['redundant_power_fail'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['redundant_power_fail'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("冗余电源离线"),
                                                      Spacer(),
                                                      if (beepControl['redundant_power_fail'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                            if (beepControl['support_reset_beep'] != null && beepControl['support_reset_beep']) ...[
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    beepControl['reset_beep'] = !beepControl['reset_beep'];
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: beepControl['reset_beep'] ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Text("系统重置"),
                                                      Spacer(),
                                                      if (beepControl['reset_beep'])
                                                        Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (fanSpeed != null)
                                  NeuCard(
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                    bevel: 10,
                                    curveType: CurveType.flat,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "风扇模式",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    fanSpeed['dual_fan_speed'] = "fullfan";
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: fanSpeed['dual_fan_speed'] == "fullfan" ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("全速模式"),
                                                            Text(
                                                              "风扇以全速工作可保持系统冷却，但会产生较大的噪音。",
                                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: 22,
                                                        child: fanSpeed['dual_fan_speed'] == "fullfan"
                                                            ? Icon(
                                                                CupertinoIcons.checkmark_alt,
                                                                color: Color(0xffff9813),
                                                                size: 22,
                                                              )
                                                            : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    fanSpeed['dual_fan_speed'] = "coolfan";
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: fanSpeed['dual_fan_speed'] == "coolfan" ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("低温模式"),
                                                            Text(
                                                              "风扇以较高的速度工作可保持系统冷却，但会产生较大的噪音。",
                                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: 22,
                                                        child: fanSpeed['dual_fan_speed'] == "coolfan"
                                                            ? Icon(
                                                                CupertinoIcons.checkmark_alt,
                                                                color: Color(0xffff9813),
                                                                size: 22,
                                                              )
                                                            : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    fanSpeed['dual_fan_speed'] = 'quietfan';
                                                  });
                                                },
                                                child: NeuCard(
                                                  decoration: NeumorphicDecoration(
                                                    color: Theme.of(context).scaffoldBackgroundColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: EdgeInsets.all(10),
                                                  bevel: 10,
                                                  curveType: fanSpeed['dual_fan_speed'] == 'quietfan' ? CurveType.emboss : CurveType.flat,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("静音模式"),
                                                            Text(
                                                              "风扇以较低的速度工作所产生的噪音较低，但过程中系统可能会变热。",
                                                              style: TextStyle(fontSize: 12, color: Colors.grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        width: 22,
                                                        child: fanSpeed['dual_fan_speed'] == 'quietfan'
                                                            ? Icon(
                                                                CupertinoIcons.checkmark_alt,
                                                                color: Color(0xffff9813),
                                                                size: 22,
                                                              )
                                                            : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: 20,
                                ),
                                if (led != null)
                                  NeuCard(
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                    bevel: 10,
                                    curveType: CurveType.flat,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "LED 亮度控制",
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Slider(
                                            value: led['led_brightness'].toDouble(),
                                            onChanged: (v) {
                                              setState(() {
                                                led['led_brightness'] = v.toInt();
                                              });
                                            },
                                            min: 0,
                                            max: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: NeuButton(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onPressed: () async {
                                var res = await Api.powerSet(enableZram, powerRecovery, beepControl, fanSpeed, led);
                                if (res['success']) {
                                  if (res['data']['has_fail'] == false) {
                                    Util.vibrate(FeedbackType.light);
                                    Util.toast("保存成功");
                                  } else {
                                    Util.vibrate(FeedbackType.warning);
                                    Util.toast("设置未完全保存成功");
                                  }
                                  getData();
                                } else {
                                  Util.toast("保存失败,代码${res['error']['code']}");
                                }
                              },
                              child: Text(
                                ' 保存 ',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: powerTasks.length > 0
                                ? ListView.builder(
                                    itemBuilder: (context, i) {
                                      return _buildPowerTaskItem(powerTasks[i]);
                                    },
                                    itemCount: powerTasks.length,
                                  )
                                : Center(
                                    child: Text(
                                      "暂无开关机计划，请点击下方新增按钮添加",
                                      style: TextStyle(color: AppTheme.of(context).placeholderColor),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NeuButton(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .push(CupertinoPageRoute(
                                              builder: (context) {
                                                return AddPowerTask(
                                                  "新增计划管理",
                                                );
                                              },
                                              settings: RouteSettings(name: "edit_power_task")))
                                          .then((value) {
                                        if (value != null) {
                                          for (var item in powerTasks) {
                                            if (item['hour'] == value['hour'] && item['min'] == value['min']) {
                                              Util.toast("无效或重复规则");
                                              Util.vibrate(FeedbackType.warning);
                                              return;
                                            }
                                          }
                                          setState(() {
                                            powerTasks.add(value);
                                          });
                                        }
                                      });
                                    },
                                    child: Text(
                                      ' 新增 ',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: NeuButton(
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onPressed: () async {
                                      List powerOns = powerTasks.where((task) => task['type'] == "power_on").map((e) {
                                        e.remove("type");
                                        return e;
                                      }).toList();
                                      List powerOffs = powerTasks.where((task) => task['type'] == "power_off").map((e) {
                                        e.remove("type");
                                        return e;
                                      }).toList();
                                      var res = await Api.powerScheduleSave(powerOns, powerOffs);
                                      if (res['success']) {
                                        Util.toast("保存成功");
                                        getData();
                                      } else {
                                        Util.toast("保存失败,代码${res['error']['code']}");
                                      }
                                    },
                                    child: Text(
                                      ' 保存 ',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "内部硬盘和外接 SATA 硬盘在闲置超过指定的时间后将进入休眠。",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder: (context) {
                                                  return NeuPicker(
                                                    dataList.map((e) => e['title']).toList(),
                                                    value: dataList.indexWhere((element) => element['value'] == hibernation['internal_hd_idletime']),
                                                    onConfirm: (v) {
                                                      setState(() {
                                                        hibernation['internal_hd_idletime'] = dataList[v]['value'];
                                                      });
                                                    },
                                                  );
                                                });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            bevel: 10,
                                            curveType: CurveType.flat,
                                            child: Row(
                                              children: [
                                                Text("时间"),
                                                Spacer(),
                                                Text("${dataList.where((element) => element['value'] == hibernation['internal_hd_idletime']).first['title']}"),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            if (hibernation['internal_hd_idletime'] > 0)
                                              setState(() {
                                                hibernation['sata_deep_sleep'] = hibernation['sata_deep_sleep'] == 1 ? 0 : 1;
                                              });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            bevel: 10,
                                            curveType: hibernation['internal_hd_idletime'] > 0 ? (hibernation['sata_deep_sleep'] == 1 ? CurveType.emboss : CurveType.flat) : CurveType.concave,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text("启动进阶硬盘休眠以将设备的耗电量降至最低"),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 22,
                                                  child: hibernation['sata_deep_sleep'] == 1
                                                      ? Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        )
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                NeuCard(
                                  decoration: NeumorphicDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  bevel: 10,
                                  curveType: CurveType.flat,
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "USB 硬盘在超过设置的闲置时间后将开始休眠（仅适用于支持休眠的 USB 设备）。",
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder: (context) {
                                                  return NeuPicker(
                                                    dataList.map((e) => e['title']).toList(),
                                                    value: dataList.indexWhere((element) => element['value'] == hibernation['usb_idletime']),
                                                    onConfirm: (v) {
                                                      setState(() {
                                                        hibernation['usb_idletime'] = dataList[v]['value'];
                                                      });
                                                    },
                                                  );
                                                });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            bevel: 10,
                                            curveType: CurveType.flat,
                                            child: Row(
                                              children: [
                                                Text("时间"),
                                                Spacer(),
                                                Text("${dataList.where((element) => element['value'] == hibernation['usb_idletime']).first['title']}"),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            if (hibernation['internal_hd_idletime'] > 0 || hibernation['usb_idletime'] > 0)
                                              setState(() {
                                                hibernation['enable_log'] = !hibernation['enable_log'];
                                              });
                                          },
                                          child: NeuCard(
                                            decoration: NeumorphicDecoration(
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            padding: EdgeInsets.all(10),
                                            bevel: 10,
                                            curveType: hibernation['internal_hd_idletime'] > 0 || hibernation['usb_idletime'] > 0 ? (hibernation['enable_log'] ? CurveType.emboss : CurveType.flat) : CurveType.convex,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text("启用硬盘休眠日志"),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 22,
                                                  child: hibernation['enable_log']
                                                      ? Icon(
                                                          CupertinoIcons.checkmark_alt,
                                                          color: Color(0xffff9813),
                                                          size: 22,
                                                        )
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (powerRecovery['wol1'] != null)
                                  NeuCard(
                                    decoration: NeumorphicDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                    bevel: 10,
                                    curveType: CurveType.flat,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "在内部硬盘休眠所配置时间段后，DS 经由局域网唤醒进入待机状态（欧盟 Lot 26 规范）。",
                                            style: TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              if (powerRecovery['wol1'] && hibernation['internal_hd_idletime'] > 0)
                                                setState(() {
                                                  hibernation['auto_poweroff_enable'] = !hibernation['auto_poweroff_enable'];
                                                  hibernation['auto_poweroff_time'] = 10;
                                                });
                                            },
                                            child: NeuCard(
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(10),
                                              bevel: 10,
                                              curveType: powerRecovery['wol1'] && hibernation['internal_hd_idletime'] > 0 ? (hibernation['auto_poweroff_enable'] ? CurveType.emboss : CurveType.flat) : CurveType.convex,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text("启用自动关机"),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  SizedBox(
                                                    width: 22,
                                                    child: hibernation['auto_poweroff_enable']
                                                        ? Icon(
                                                            CupertinoIcons.checkmark_alt,
                                                            color: Color(0xffff9813),
                                                            size: 22,
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (hibernation['auto_poweroff_enable'])
                                                showCupertinoModalPopup(
                                                    context: context,
                                                    builder: (context) {
                                                      return NeuPicker(
                                                        dataList.getRange(1, dataList.length).map((e) => e['title']).toList(),
                                                        value: dataList.indexWhere((element) => element['value'] == hibernation['auto_poweroff_time']) - 1,
                                                        onConfirm: (v) {
                                                          setState(() {
                                                            hibernation['auto_poweroff_time'] = dataList[v]['value'];
                                                          });
                                                        },
                                                      );
                                                    });
                                            },
                                            child: NeuCard(
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              padding: EdgeInsets.all(10),
                                              bevel: 10,
                                              curveType: hibernation['auto_poweroff_enable'] ? CurveType.flat : CurveType.convex,
                                              child: Row(
                                                children: [
                                                  Text("时间"),
                                                  Spacer(),
                                                  Text("${hibernation['auto_poweroff_enable'] ? dataList.where((element) => element['value'] == hibernation['auto_poweroff_time']).first['title'] : ""}"),
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
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: NeuButton(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onPressed: () async {
                                var res = await Api.powerHibernationSave(
                                  internalHdIdletime: hibernation['internal_hd_idletime'],
                                  sataDeepSleep: hibernation['sata_deep_sleep'] == 1,
                                  usbIdletime: hibernation['usb_idletime'],
                                  enableLog: hibernation['enable_log'],
                                  autoPoweroffEnable: hibernation['auto_poweroff_enable'],
                                  autoPoweroffTime: hibernation['auto_poweroff_time'],
                                );
                                if (res['success']) {
                                  Util.toast("保存成功");
                                  getData();
                                } else {
                                  Util.toast("保存失败,代码${res['error']['code']}");
                                }
                              },
                              child: Text(
                                ' 保存 ',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Text("待开发"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
