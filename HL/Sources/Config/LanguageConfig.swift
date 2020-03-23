//
//  LanguageConfig.swift  多语言配置文件
//  TelegramCore
//
//  Created by 黄国坚 on 2019/11/13.
//  Copyright © 2019 Peter. All rights reserved.
//

import Foundation

///语言枚举
public enum LanguageCodeEnum: String {
    ///简体
    case SC = "zh-hans-raw"
    ///繁体
    case TC = "zh-hant-raw"
    ///英文
    case EN = "en"
}

public protocol LocalizableProtocol{
    static var language: (sc: String, tc: String, en: String) {get}
}
public extension LocalizableProtocol{
    ///多语言
    static func localized() -> String{return str}
    ///多语言
    static var str : String{
        
        //FIXME: -  记得改回去
        //let code = HLAccountManager.shareLanguageCode
        let code = LanguageCodeEnum.SC
        
        switch code {
        case .SC:
            return language.sc
        case .TC:
            return language.tc
        case .EN:
            return language.en
        }
    }
}

public class HL{
    
}
extension HL{

//MARK: - 海螺相关的多语言
    public class Language {
        
        //MARK: - tabbar相关
        public class Tabbar {
            
            /// tabbbar item “发现”
            public class Discover : LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("发现",
                       "發現",
                       "Discover")
            }
        }
        
        //MARK: - 手势验证
        public class GesturesUnlock {
            ///页面头部标题
            public class HeadTitle{
                /// 设置手势
                public class Set: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("设置账户手势密保",
                           "設置賬戶手勢密保",
                           "Set account gesture encryption")
                }
                /// 重复手势
                public class Repeat: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("重复手势密保",
                           "重複手勢密保",
                           "Repeat gesture encryption")
                }
                /// 手势解锁
                public class Unlock: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("请输入账户手势密保",
                           "請輸入賬戶手勢密保",
                           "Please enter account gesture protection")
                }
            }
            ///跳转按钮
            public class Jump{
                ///找回密保
                public class Reset: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("找回密保",
                           "找回密保",
                           "Find encrypted")
                }
                ///去验证手机
                public class PhoneVerification: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("去验证手机",
                           "去驗證手機",
                           "To verify the phone")
                }
            }
            /// 手势错误相关
            public class Error{
                /// 解锁失败
                public class Unlock: LocalizableProtocol{
                    private static var count: String = "0"
                    public static func setCount(_ c: String) -> Unlock.Type{
                        let cInt = Int(c) ?? 0
                        count = "\(5 - cInt)"
                        return Unlock.self
                    }
                    public static var language: (sc: String, tc: String, en: String){
                        return ("解锁失败,您还可以尝试\(count)次",
                            "解鎖失敗,您還可以嘗試\(count)次",
                            "Unlocking failed, you can try again \(count) times")
                    }
                }
                /// 手势密码长度不够
                public class Length: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("至少链接4个点",
                           "至少鏈接4個點",
                           "Link at least 4 points")
                }
                /// 重设的手势密码不一致
                public class NotTheSame: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("与上次手势密保不一致，请重新输入",
                           "與上次手勢密保不一致，請重新輸入",
                           "It is not the same as last time, please retype it")
                }
            }
            /// 密保成功相关
            public class Success{
                /// 密保设置成功
                public class Set: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("密保设置成功",
                           "密保設置成功",
                           "Security settings succeeded")
                }
                /// 解锁成功
                public class Unlock: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("解锁成功",
                           "解鎖成功",
                           "Unlock success")
                }
                
            }
        }
        
        //MARK: - 交易记录相关
        public class Record: LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易记录",
                   "交易記錄",
                   "Record")
            
            /// 闪兑记录
            public class Flash: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("闪兑记录",
                       "閃兌記錄",
                       "Flash record")
            }
            /// 提现记录
            public class Withdrawal : LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("提现记录",
                       "提現記錄",
                       "Record of withdrawal")
            }
            /// 转账记录
            public class Transfer : LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("转账记录",
                       "轉賬記錄",
                       "Transfer record")
            }
            /// 红包记录
            public class RedPacket: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("红包记录",
                       "紅包記錄",
                       "Red packet records")
            }
        }
        
        //MARK: - 会话页面相关
        public class Chat{
            ///会话页面弹出的菜单（用于发红包，闪兑等等）
            public class Menu{
                public class shooting: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("拍摄",
                           "拍攝",
                           "Shooting")
                }
                public class photo: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("相册",
                           "相冊",
                           "Photo")
                }
                public class location: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("位置",
                           "位置",
                           "Location")
                }
                public class contact: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("联系人",
                           "聯繫人",
                           "Contact")
                }
                public class file: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("文件",
                           "文件",
                           "File")
                }
                public class poll: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("投票",
                           "投票",
                           "Poll")
                }
            }
        }
        
        //MARK: - 海螺默认代理相关
        public struct Proxy{
            
            public struct Success{
                public struct Set: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("代理设置成功",
                           "代理設置成功",
                           "Proxy setup successful")
                    
                }
            }
            public struct Fail{
                public struct Set: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("代理设置失败",
                           "代理設置失敗",
                           "Proxy setup failed")
                }
            }
            ///代理线路
            public struct Channel: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String) {
                    return ("线路\(index)",
                        "線路\(index)",
                        "Proxy\(index)")
                }
                
                private static var index: Int = 1
                public static func setIndex(_ i: Int) -> Channel.Type{
                    index = i
                    return Channel.self
                }
            }
            
            
        }
        //MARK: -
        public struct Invitation{
            public struct title: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("海螺内测码",
                       "海螺內測碼",
                       "HaiLuo Private yards")
            }
            public struct placeHolder: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("请输入内测码",
                       "請輸入內測碼",
                       "Please enter the internal code")
            }
        }
        
        //MARK: -  红包 HL.RedPacket.localized()
        public class RedPacket : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包",
                   "紅包",
                   "Gift")
            
            ///总金额
            public class SubAmount: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("总金额",
                       "總金額",
                       "Total")
                
            }
            ///单个金额
            public class PerAmount: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("单个金额",
                       "單個金額",
                       "Amount")
            }
        }
        
        //MARK: - 超级红包相关
        public class SuperRedPacket{
            ///發送
            public class send: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("发超级红包",
                       "發超級紅包",
                       "Send Super Red Packets"
                )
            }
            ///領取
            public class get: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("领取超级红包",
                       "領取超級紅包",
                       "Get Super Red Packets"
                )
            }
            
            ///退款
            public class refund: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("超级红包退回",
                       "超級紅包退回",
                       "Super Red Packets Refund"
                )
            }
            
        }
        
        //MARK: - 流水\交易
        public class Transaction{
            public class Detail{
                
                public class TypeKey : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("类      型",
                           "類      型",
                           "Type")
                }
                public class Remarks : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("备      注",
                           "備      註",
                           "Remarks")
                }
                public class Memo : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("标      签",
                           "標      籤",
                           "Tag")
                }
                public class Explain : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("说      明",
                           "說      明",
                           "Explain")
                }
                public class from: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("来      自",
                           "來      自",
                           "From")
                }
                public class superpacketPwd: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("口      令",
                           "口      令",
                           "Password")
                }
                public class Transfer : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("转      账",
                           "轉      賬",
                           "Transfer")
                }
                public class Exchange : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("兑      换",
                           "兌      換",
                           "Exchange")
                }
                /// 退回 HL.Return1.localized()
                public class Refund : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("退      回",
                           "退      回",
                           "Return")
                }
                public class progress: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("完 成 度",
                           "完 成 度",
                           "progress")
                }
                public class ServiceCharge : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("手 续 费",
                           "手 續 費",
                           "Service Charge")
                }
                public class Sender : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("发 送 人",
                           "發 送 人",
                           "Sender")
                }
                
                public class Receiver : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("领 取 人",
                           "領 取 人",
                           "Receiver")
                }
                
                public class Convertibility : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("已 兑 换",
                           "已 兌 換",
                           "Convertibility")
                }
                
                ///交易时间
                public class Time: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("交易时间",
                           "交易時間",
                           "Time")
                }
                
                public class numner: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("交易编号",
                           "交易編號",
                           "Trading number")
                }
                
                
                public class releaseTime: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("发布时间",
                           "發佈時間",
                           "Release time")
                }
                
                public class exchangeSender: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("挂单用户",
                           "掛單用戶",
                           "List user")
                }
                
                public class sendTime : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("发送时间",
                           "發送時間",
                           "Send time")
                }
                public class getCount : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("领取个数",
                           "領取個數",
                           "NO.")
                }
                public class getAmount : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("领取金额",
                           "領取金額",
                           "Money")
                }
                public class redpacketWaiting : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("待领取",
                           "待領取",
                           "Pending receive")
                }
                public class received : LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("已领取",
                           "已領取",
                           "Received")
                }
            }
        }
        
        //MARK: - 币种相关
        public class Currency: LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("币种",
                   "幣種",
                   "Currency")
            
            ///提现
            class withdrawal: LocalizableProtocol{
                static var language: (sc: String, tc: String, en: String)
                    = ("   提现",
                       "   提現",
                       "   Withdrawal")
                
            }
            ///充值
            class recharge: LocalizableProtocol{
                static var language: (sc: String, tc: String, en: String)
                    = ("   充值",
                       "   充值",
                       "   Recharge")
            }
        }
        
        //MARK: - 财路相关
        public class CaiLu{
            
            public class Send: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("向财路转账",
                       "向財路轉賬",
                       "Transfer to CaiLu")
            }
            
            public class TransferStatus: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("转账结果",
                       "轉賬結果",
                       "Result Of Transfer")
                
                public class success: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("转账成功",
                           "轉賬成功",
                           "Successful transfer")
                }
                public class fail: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("交易失败",
                           "交易失敗",
                           "Transaction failure")
                }
                public class processing: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("处理中",
                           "處理中",
                           "In the processing")
                }
            }
            
            public class timeOutBack: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("自动返回",
                       "自動返回",
                       "Automatic return")
            }
        }
        
        //MARK: - 邀请好友
        public class Invite{
            
            //扫码注册海螺APP
            public class Title: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("扫码注册海螺APP",
                       "掃碼註冊海螺APP",
                       "Scan code to register")
                
            }
            ///已邀请好友数
            public class Count: LocalizableProtocol{
                private static var count: Int = 0
                public static func set(_ c: Int) -> Count.Type{
                    count = c
                    return Count.self
                }
                public static var language: (sc: String, tc: String, en: String){
                    return ("已邀请好友：\(count)人",
                        "已邀請好友：\(count)人",
                        "Invited friends: \(count)")
                }
                
            }
        }
        
        /// 恭喜发财，大吉大利 HL.Congratulations.localized()
        public class Congratulations : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("恭喜发财，大吉大利",
                   "恭喜發財，大吉大利",
                   "Wish you good fortune and every success")
        }
        
        /// 闪兑 HL.FastExchange.localized()
        public class FastExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("闪兑",
                   "閃兌",
                   "Exchange")
        }
        
        /// 转账 HL.Transfer.localized()
        public class Transfer : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账",
                   "轉賬",
                   "EFT")
            
            /// 转账备注
            public class Remark: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("转账备注",
                       "轉賬備註",
                       "Transfer note")
            }
            /// 发送和接收转账时，如果备注为空，则显示转账给你
            public class messageTip: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("转账给你",
                       "轉賬給你",
                       "Transfer money to you")
            }
        }
        
        /// 转账退回 HL.ReturnOfTransfer.localized()
        public class ReturnOfTransfer : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账退回",
                   "轉帳退回",
                   "Return of transfer")
        }
        
        /// 兑换 HL.Exchange.localized()
        public class Exchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换",
                   "兌換",
                   "Exchange")
        }
        
        /// 确认兑换 HL.ConfirmationOfExchange.localized()
        public class ConfirmationOfExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认兑换",
                   "確認兌換",
                   "Confirmation of exchange")
        }
        
        /// 当前汇率 HL.CurrentExchangeRate.localized()
        public class CurrentExchangeRate : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("当前汇率",
                   "當前匯率",
                   "Current exchange rate")
        }
        
        /// 正在交易 HL.TradingNow.localized()
        public class TradingNow : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("正在交易",
                   "正在交易",
                   "Trading now")
        }
        
        /// 发红包 HL.SendRedPacket.localized()
        public class SendRedPacket : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发红包",
                   "發紅包",
                   "Send a gift")
        }
        
        /// 超级红包 HL.SendSuperPacketMenu.localized()
        public class SendSuperPacketMenu : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("超级红包",
                   "超级红包",
                   "Super Gift")
        }
        
        /// 超级红包 HL.SendSuperPacketFail.localized()
        public class SendSuperPacketFail : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发送超级红包失败",
                   "发送超级红包失败",
                   "Send Super Gift Fail")
        }
        
        /// 超级红包 HL.SuperPacketReward.localized()
        public class SuperPacketReward : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包领取口令:",
                   "红包领取口令:",
                   "Password:")
        }
        
        /// 撤销 HL.Revoke.localized()
        public class Revoke : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("撤销",
                   "撤銷",
                   "Revoke")
        }
        
        /// 选择币种 HL.ChooseCurrencies.localized()
        public class ChooseCurrencies : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("选择币种",
                   "選擇幣種",
                   "Select currency")
        }
        
        /// 红包金额 HL.AmountOfRedPacket.localized()
        public class AmountOfRedPacket : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包金额",
                   "紅包金額",
                   "Amount")
        }
        
        /// 把币装进红包 HL.PutCoinInRedPacket.localized()
        public class PutCoinInRedPacket : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("塞进红包",
                   "塞進紅包",
                   "Send a gift")
        }
        
        /// 未领取的红包，将于24小时后发起退款 HL.RedpacketTip.localized()
        public class RedpacketTip : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("未领取的红包，将于24小时后发起退款",
                   "未領取的紅包，將於24小時後發起退款",
                   "Unclaimed gifts will be refunded after 24 hours")
        }
        
        /// 转账未确认将在24小时后退回 HL.TransferTip.localized()
        public class TransferTip : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账未确认将在24小时后退回",
                   "轉帳未確認將在24小時後退回",
                   "Unconfirmed transfer will be returned in 24 hours")
        }
        
        /// 币种选择 HL.CurrencyChoice.localized()
        public class CurrencyChoice : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("币种选择",
                   "幣種選擇",
                   "Select currency")
        }
        
        /// 搜索币种 HL.SearchCurrency.localized()
        public class SearchCurrency : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("搜索币种",
                   "搜索幣種",
                   "Search currency")
        }
        
        /// 转账金额 HL.TransferAmount.localized()
        public class TransferAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账金额",
                   "轉賬金額",
                   "Transfer amount")
        }
        
        /// 确认转账 HL.ConfirmTransfer.localized()
        public class ConfirmTransfer : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认转账",
                   "確認轉賬",
                   "Confirm transfer")
        }
        
        /// 群组/频道 HL.GroupsAndChannels.localized()
        public class GroupsAndChannels : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群组/频道",
                   "群組/頻道",
                   "Group/channel")
        }
        
        /// 我创建的群 HL.GroupsIcreated.localized()
        public class GroupsIcreated : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我创建的群",
                   "我創建的群",
                   "Created")
        }
        
        /// 我管理的群 HL.GroupsImanage.localized()
        public class GroupsImanage : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我管理的群",
                   "我管理的群",
                   "Manage")
        }
        
        /// 我加入的群 HL.GroupsIjoin.localized()
        public class GroupsIjoin : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我加入的群",
                   "我加入的群",
                   "Join")
        }
        
        /// 群组 HL.Group2.localized()
        public class Group2 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群组",
                   "群組",
                   "Group")
        }
        
        /// 频道 HL.Channel.localized()
        public class Channel : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("频道",
                   "頻道",
                   "Channel")
        }
        
        /// 我创建的频道 HL.ChannelsIcreated.localized()
        public class ChannelsIcreated : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我创建的频道",
                   "我創建的頻道",
                   "Created")
        }
        
        /// 我管理的频道 HL.ChannelsImanage.localized()
        public class ChannelsImanage : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我管理的频道",
                   "我管理的頻道",
                   "Manage")
        }
        
        /// 我加入的频道 HL.ChannelsIjoined.localized()
        public class ChannelsIjoined : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我加入的频道",
                   "我加入的頻道",
                   "Join")
        }
        
        /// 我的资产 HL.MyAssets.localized()
        public class MyAssets : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我的资产",
                   "我的資產",
                   "MyAssets")
        }
        
        //MARK: - 资产相关
        public class Assets : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("资产",
                   "資產",
                   "Assets")
            
            public class Info: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("资产信息",
                       "資產信息",
                       "Asset information")
            }
            
            public class Transfer: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("资产转移",
                       "資產轉移",
                       "Asset transfers"
                )
                public class Action: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("转移账户资产",
                           "轉移賬戶資產",
                           "Transfer account assets")
                }
                public class Account: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("资产转移账号",
                           "資產轉移賬號",
                           "Asset transfer account")
                    
                }
                public class Confirm: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("确认转移",
                           "確認轉移",
                           "Confirm the transfer")
                }
                
                public class Success: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("转移成功",
                           "轉移成功",
                           "Transfer Success"
                    )
                }
                public class PhoneVerify: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("进行手机号验证",
                           "進行手機號驗證",
                           "Verify your phone number")
                }
                
                public class TransferTip: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("电报（Telegram）账号规则封禁了您的海螺账号，海螺资产转移 功能将保证您的资产安全：\n1.填写账户必须为海螺用户，且填写账户已经进行过资产验证；\n2.填写账户资产钱包验证无异常。",
                           "電報（Telegram）賬號規則封禁了您的海螺賬號，海螺資產轉移功能將保證您的資產安全：\n1.填寫賬戶必須為海螺用戶，且填寫賬戶已經進行資產驗證；\n2.填寫賬戶資產錢包驗證無異常。",
                           "Telegram account rules ban your conch account. The conch asset transfer function will ensure the security of your assets:\n1. The account must be filled by a conch user, and the account has been verified by assets;\n2. Fill in the account asset wallet to verify that there is no abnormality."
                    )
                    
                }
                public class EmptyTip1: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("当前暂无可转移的资产，若您进行过充值或进行过提币操作，则请稍后重新登录进行转移操作。",
                           "當前暫無可轉移的資產，若您進行過充值或進行過提幣操作，則請稍後重新登錄進行轉移操作。",
                           "If you have recharged or withdrawn money, please log in again later to transfer the assets that are currently not transferable."
                    )
                }
                public class EmptyTip2: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("1.若您有转账未进行确认领取，则请转账方撤销转账；\n2.若您有进行过提现，充值操作，则当前资产转移仅转移当前可用资产，未到账的账户资产可稍后再次登陆进行转移。",
                           "1.若您有轉賬未進行確認領取，則請轉賬方撤銷轉賬；\n2.若您有進行過提現，充值操作，則當前資產轉移僅轉移當前可用資產，未到賬的賬戶資產可稍後再次登錄進行轉移。",
                           "1. If you do not confirm the receipt of the transfer, please cancel the transfer;\n2. If you have carried out withdrawal and recharge operations, the current asset transfer only transfers the currently available assets, and the account assets not received can be logged in again later for transfer."
                    )
                }
                public class LockTip: LocalizableProtocol{
                    public static var language: (sc: String, tc: String, en: String)
                        = ("您的海螺账号因资产密码错误次数超限\n账号已被限制登录，24小时后限制自动解除",
                           "您的海螺賬號因資產密碼錯誤次數超限\n賬號已被限制登錄，24小時後限制自動解除",
                           "Your whelk account has exceeded the limit due to the number of asset password errors\nThe account has been restricted to login, and the restriction will be automatically lifted after 24 hours"
                    )
                    
                }
            }
        }
        
        /// 勾选代表同意《海螺用户隐私政策及服务协议》 HL.UserProtocol.localized()
        public class UserProtocolPart1 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("勾选代表同意《",
                   "勾選代表同意《",
                   "Tick the delegates to agree to the 《")
        }
        
        public class UserProtocolPart2 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺用户隐私政策及服务协议",
                   "海螺用戶隱私政策及服務協定",
                   "HaiLuo user privacy policy and service agreement")
        }
        
        public class UserProtocolPart3 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("》",
                   "》",
                   "》.")
        }
        
        
        /// 设置 HL.Setup.localized()
        public class Setup : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("设置",
                   "設置",
                   "Setting")
        }
        
        /// 关于海螺 HL.AboutConch.localized()
        public class AboutConch : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("关于海螺",
                   "關於海螺",
                   "About HaiLuo")
        }
        
        /// 手机绑定异常 HL.MobilePhoneBindingException.localized()
        public class MobilePhoneBindingException : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("手机绑定异常",
                   "手機綁定異常",
                   "Phone binding exception")
        }
        
        /// 手机绑定异常，请输入交易密码验证 HL.EnterTransactionPasswordVerification.localized()
        public class EnterTransactionPasswordVerification : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("手机绑定异常，请输入交易密码验证",
                   "手機綁定異常，請輸入交易密碼驗證",
                   "Phone binding is abnormal, please enter transaction password verification")
        }
        
        /// 请输入交易密码验证 HL.TransactionPasswordVerification.localized()
        public class TransactionPasswordVerification : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入交易密码验证",
                   "請輸入交易密碼驗證",
                   "Please enter the transaction password verification")
        }
        
        /// 去验证手机 HL.ToverifyPhone.localized()
        public class ToverifyPhone : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("去验证手机",
                   "去驗證手機",
                   "Verify phone")
        }
        
        /// 为了保证资金安全，需要进行手机验证 HL.MobilePhoneVerification.localized()
        public class MobilePhoneVerification : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("为了保证资金安全，需要进行手机验证",
                   "為了保證資金安全，需要進行手機驗證",
                   "In order to ensure the security of funds, mobile phone verification is required.")
        }
        
        /// 输入验证码 HL.EnterVerificationcode.localized()
        public class EnterVerificationcode : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("输入验证码",
                   "輸入驗證碼",
                   "Enter confirmation code")
        }
        
        /// 获取验证码 HL.GetVerificationcode.localized()
        public class GetVerificationcode : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("获取验证码",
                   "獲取驗證碼",
                   "Get verification code")
        }
        
        /// 验证 HL.Verification.localized()
        public class Verification : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("验证",
                   "驗證",
                   "Verification")
        }
        
        /// 登陆 HL.Login.localized()
        public class Login : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("登录",
                   "登入",
                   "Login")
        }
        
        
        /// 交易密码修改 HL.ChangeTransactionPassword.localized()
        public class ChangeTransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易密码修改",
                   "交易密碼修改",
                   "Transaction password modification")
        }
        
        /// 请输入6位数字交易密码 HL.PleasEenter6DigitTransactionPassword.localized()
        public class PleasEenter6DigitTransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入6位数字交易密码",
                   "請輸入6位數字交易密碼",
                   "Please enter a 6 digit transaction password")
        }
        
        /// 请重复输入密码 HL.PleaseReenterPassword.localized()
        public class PleaseReenterPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请重复输入密码",
                   "請重復輸入密碼",
                   "Please enter your password repeatedly")
        }
        
        /// 完成 HL.Complete.localized()
        public class Complete : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("完成",
                   "完成",
                   "Finish")
        }
        
        /// 请上传照片 HL.PleaseUploadPhotos.localized()
        public class PleaseUploadPhotos : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请上传照片",
                   "請上傳照片",
                   "Please upload photos")
        }
        
        /// 暂时不绑定 HL.DoNotBindTemporarily.localized()
        public class DoNotBindTemporarily : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("暂时不绑定",
                   "暫時不綁定",
                   "Temporarily not bound")
        }
        
        /// 海螺帐号登陆 HL.ConchAccountLogin.localized()
        public class ConchAccountLogin : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺帐号登陆",
                   "海螺帳號登陸",
                   "Hailuo login")
        }
        
        /// 请输入手机号码 HL.PleaseEnterYourMobileNumber.localized()
        public class PleaseEnterYourMobileNumber : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入手机号码",
                   "請輸入手機號碼",
                   "Please Enter Your Mobile Number")
        }
        
        /// 若登录未注册财路，系统将自动生成财路账号进行绑定。\n未绑定财路账户，则海螺部分功能将无法使用 HL.BindTip.localized()
        public class BindTip : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("若登录未注册财路，系统将自动生成财路账号进行绑定。未绑定财路账户，则海螺部分功能将无法使用",
                   "若登錄未註冊財路，系統將自動生成財路賬號進行綁定。未綁定財路賬戶，則海螺部分功能將無法使用",
                   "If you log in to an unregistered financial channel, the system will automatically generate a financial account to bind. If the financial account is not bound, some of the HaiLuo functions will not be available.")
        }
        
        /// 海螺部分功能需要绑定财路账户 HL.NeedtoBindCailuAccount.localized()
        public class NeedtoBindCailuAccount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺部分功能需要绑定财路账户",
                   "海螺部分功能需要綁定財路賬戶",
                   "Some of the HaiLuo functions need to be bound to the financial account.")
        }
        
        /// 确认绑定 HL.ConfirmBinding.localized()
        public class ConfirmBinding : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认绑定",
                   "確認綁定",
                   "Confirm binding")
        }
        
        /// 确认 HL.Confirm.localized()
        public class Confirm : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认",
                   "確認",
                   "Confirm")
        }
        
        /// 交易撤销后，剩余%@\n将退回到您的账户中，具体额度以到账为准 HL.ExchangeRevokeTip.localized()
        public class ExchangeRevokeTip : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易撤销后，剩余%@\n将退回到您的账户中，具体额度以到账为准",
                   "交易撤銷後，剩餘%@\n將退回到您的帳戶中，具體額度以到賬為准",
                   "After the transaction is cancelled \n %@ will be returned to your account, and the specific amount shall be subject to the payment")
        }
        
        
        /// 是否确认撤销 HL.ConfirmCancellationOrNot.localized()
        public class ConfirmCancellationOrNot : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("是否确认撤销",
                   "確認",
                   "Confirm cancellation or not")
        }
        
        /// 确认撤销 HL.ConfirmCancellation.localized()
        public class ConfirmCancellation : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认撤销",
                   "確認撤銷",
                   "Confirm cancellation")
        }
        
        /// 验证码 HL.VerificationCode.localized()
        public class VerificationCode : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("验证码",
                   "驗證碼",
                   "Verification code")
        }
        
        /// 交易密码 HL.TransactionPassword.localized()
        public class TransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易密码",
                   "交易密碼",
                   "Transaction password")
        }
        
        /// 重复密码 HL.RepeatPassword.localized()
        public class RepeatPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("重复密码",
                   "重復密碼",
                   "Repeat the password")
        }
        
        /// 加载更多 HL.LoadMore.localized()
        public class LoadMore : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("加载更多",
                   "加載更多",
                   "Load more")
        }
        
        /// 努力加载中... HL.TryingToLoad.localized()
        public class TryingToLoad : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("努力加载中...",
                   "努力加載中...",
                   "Trying to load...")
        }
        
        /// 只有这么多啦～ HL.ThereAreOnlySoMany.localized()
        public class ThereAreOnlySoMany : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("只有这么多啦～",
                   "只有這麽多啦～",
                   "Only so much~")
        }
        
        /// 转出地址 HL.RollOutAddress.localized()
        public class RollOutAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转出地址",
                   "轉出地址",
                   "Transfer address")
        }
        
        /// 转出账号 HL.TransferredAccount.localized()
        public class TransferredAccount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转出账号",
                   "轉出賬號",
                   "Transfer account")
        }
        
        /// 转入账号 HL.TransferToAccount.localized()
        public class TransferToAccount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转入账号",
                   "轉入賬號",
                   "Transfer to account")
        }
        
        /// 处理中 HL.InProcessing.localized()
        public class InProcessing : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("处理中",
                   "處理中",
                   "Processing")
        }
        
        /// 提现成功 HL.SuccessfulMentionOfCurrency.localized()
        public class SuccessfulMentionOfCurrency : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现成功",
                   "提現成功",
                   "Successful coin")
        }
        
        /// 保存成功 HL.SaveSuccessfully.localized()
        public class SaveSuccessfully : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("保存成功",
                   "保存成功",
                   "Save successfully")
        }
        
        /// 提现失败已解冻 HL.FailedToWithdrawCurrencyHasBeenUnfrozen.localized()
        public class FailedToWithdrawCurrencyHasBeenUnfrozen : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现失败 已解冻",
                   "提現失敗 已解凍",
                   "Unsuccessful withdrawal of coins")
        }
        
        /// 审核中 HL.InAudit.localized()
        public class InAudit : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("审核中",
                   "審核中",
                   "Under review")
        }
        
        /// 审核不通过 HL.AuditFailed.localized()
        public class AuditFailed : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("审核不通过",
                   "審核不通過",
                   "Audit not passed")
        }
        
        /// 待确认 HL.ToBeConfirmed.localized()
        public class ToBeConfirmed : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("待确认",
                   "待確認",
                   "To be confirmed")
        }
        /// 支付成功 HL.SuccessfulPayment.localized()
        public class SuccessfulPayment : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支付成功",
                   "支付成功",
                   "Successful payment")
        }
        
        /// 全部兑换 HL.AllConvertibility.localized()
        public class AllConvertibility : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("全部兑换",
                   "全部兌換",
                   "All convertibility")
        }
        
        /// 全部提现 HL.AllWithdrawals.localized()
        public class AllWithdrawals : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("全部提现",
                   "全部提現",
                   "All withdrawals")
        }
        
        /// 提现 HL.Withdrawals.localized()
        public class Withdrawals : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现",
                   "提現",
                   "Withdrawals")
            
            public class NotEnough: LocalizableProtocol{
                public static var language: (sc: String, tc: String, en: String)
                    = ("可用余额不足",
                       "可用餘額不足",
                       "Available balance is insufficient")
                
            }
        }
        
        /// 全部交易 HL.AllTransactions.localized()
        public class AllTransactions : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("全部交易",
                   "全部交易",
                   "All transactions")
        }
        
        /// 转账成功 HL.SuccessfulTransfer.localized()
        public class SuccessfulTransfer : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账成功",
                   "轉賬成功",
                   "Successful transfer")
        }
        
        /// 交易详情 HL.TransactionDetails.localized()
        public class TransactionDetails : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易详情",
                   "交易詳情",
                   "Transaction details")
        }
        
        /// 暂无记录 HL.NoRecord.localized()
        public class NoRecord : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("暂无记录",
                   "暫無記錄",
                   "No record")
        }
        
        /// 已退还 HL.Returned.localized()
        public class Returned : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已退还",
                   "已退還",
                   "Returned")
        }
        
        /// 已抢完 HL.TakeUp.localized()
        public class TakeUp : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已抢完",
                   "已抢完",
                   "Had Take Up")
        }
        
        /// 已被领取 HL.BeReceived.localized()
        public class BeReceived : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已被领取",
                   "已被领取",
                   "Be Received")
        }
        
        /// 普通红包 HL.OrdinaryRedEnvelope.localized()
        public class OrdinaryRedEnvelope : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("普通红包",
                   "普通紅包",
                   "Ordinary red envelope")
        }
        
        /// 群红包-拼手气红包 HL.GroupRedEnvelopesLuckyRedEnvelopes.localized()
        public class GroupRedEnvelopesLuckyRedEnvelopes : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群红包（拼手气红包）",
                   "群紅包（拼手氣紅包）",
                   "Group red envelopes（lucky red envelopes）")
        }
        
        /// 群红包-普通红包 HL.GroupRedEnvelopeOrdinaryRedEnvelope.localized()
        public class GroupRedEnvelopeOrdinaryRedEnvelope : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群红包（普通红包）",
                   "群紅包（普通紅包）",
                   "Group red envelope（ordinary red envelope）")
        }
        
        /// 发送 HL.SendOut.localized()
        public class SendOut : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发送",
                   "發送",
                   "Send out")
        }
        
        /// 退回 HL.Return1.localized()
        public class Return1 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("退回",
                   "退回",
                   "Return")
        }
        
        /// 领取 HL.Receive.localized()
        public class Receive : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("领取",
                   "領取",
                   "Receive")
        }
        
        /// 红包已抢光 HL.TheRedBagHasBeenRobbed.localized()
        public class TheRedBagHasBeenRobbed : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包已抢光",
                   "紅包已搶光",
                   "The red bag has been robbed")
        }
        
        /// 红包已过期 HL.RedPacketExpired.localized()
        public class RedPacketExpired : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包已过期",
                   "紅包已過期",
                   "Red packet expired")
        }
        
        /// 客服电话 HL.CustomerServiceTelephoneNumbers.localized()
        public class CustomerServiceTelephoneNumbers : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("客服电话",
                   "客服電話",
                   "Customer service telephone numbers")
        }
        
        /// 客服邮箱 HL.CustomerServiceMailbox.localized()
        public class CustomerServiceMailbox : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("客服邮箱",
                   "客服郵箱",
                   "Customer service mailbox")
        }
        
        /// 当前账户已锁定请24小时后再试，或联系客服 HL.CurrentAccountLocked.localized()
        public class CurrentAccountLocked : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("当前账户已锁定\n请24小时后再试，或联系客服",
                   "當前賬戶已鎖定\n請24小時後再試，或聯系客服",
                   "The current account is locked \n Please try again in 24 hours or contact customer service")
        }
        
        /// 当前账户数据异常，请联系客服 HL.CurrentAccountShielding.localized()
        public class CurrentAccountShielding : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("当前账户数据异常，请联系客服",
                   "當前帳戶數據异常，請聯系客服",
                   "The current account data is abnormal, please contact customer service")
        }
        
        /// 客服电话：020-86242424 客服邮箱：456895210@qq.com HL.ServiceInformation.localized()
        public class ServiceInformation : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺客服：@haloservice\n客服邮箱：hailuo456@gmail.com",
                   "海螺客服：@haloservice\n客服郵箱：hailuo456@gmail.com",
                   "Customer service：@haloservice\nCustomer service mailbox：hailuo456@gmail.com")
        }
        
        /// 海螺客服： HL.ServiceInfo.localized()
        public class ServiceInfo : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺客服：",
                   "海螺客服：",
                   "Customer service：")
        }
        
        /// 客服邮箱： HL.ServiceEmail.localized()
        public class ServiceEmail : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("客服邮箱：",
                   "客服邮箱：",
                   "Customer service Email：")
        }
        
        /// 请输入验证码 HL.PleaseEnterTheVerificationCode.localized()
        public class PleaseEnterTheVerificationCode : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入验证码",
                   "請輸入驗證碼",
                   "Please enter the verification code")
        }
        
        /// 原绑定手机号码 HL.OriginalBindingMobileNumber.localized()
        public class OriginalBindingMobileNumber : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("原绑定手机号码",
                   "原綁定手機號碼",
                   "Original binding mobile number")
        }
        
        /// 去验证交易密码 HL.ToVerifyTheTransactionPassword.localized()
        public class ToVerifyTheTransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("去验证交易密码",
                   "去驗證交易密碼",
                   "To verify the transaction password")
        }
        
        /// 若登录未注册财路，系统将自动生成财路账号进行绑定。\n未绑定财路账户，则海螺部分功能将无法使用。 HL.CailuReminder.localized()
        public class CailuReminder : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("若登录未注册财路，系统将自动生成财路账号进行绑定。\n未绑定财路账户，则海螺部分功能将无法使用。",
                   "若登錄未註冊財路，系統將自動生成財路賬號進行綁定。\n未綁定財路賬戶，則海螺部分功能將無法使用。",
                   "If you log in and do not register with Cailu, the system will automatically generate Cailu account for binding.\n If the account of Cailu is not bound, some functions of HaiLuo will not be available. ")
        }
        
        /// 绑定成功 HL.BindingSuccess.localized()
        public class BindingSuccess : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("绑定成功",
                   "綁定成功",
                   "Binding success")
        }
        
        /// 绑定失败，请稍后再试 HL.BindingFailedPleaseTryAgainLater.localized()
        public class BindingFailedPleaseTryAgainLater : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("绑定失败，请稍后再试",
                   "綁定失敗，請稍後再試",
                   "Binding failed, please try again later")
        }
        
        /// 跳过 HL.Skip.localized()
        public class Skip : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("跳过",
                   "跳過",
                   "Skip")
        }
        
        /// 兑出币种 HL.CurrencyOutExchange.localized()
        public class CurrencyOutExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑出币种",
                   "兌出幣種",
                   "sell")
        }
        
        /// 兑入币种 HL.CurrencyInExchange.localized()
        public class CurrencyInExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑入币种",
                   "兌入幣種",
                   "buy")
        }
        
        /// 最低兑换数量 HL.MinimumLowExchangeQuantity.localized()
        public class MinimumLowExchangeQuantity : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低兑换数量",
                   "最低兌換數量",
                   "Min exchange num")
        }
        
        /// 兑换数量 HL.ExchangeQuantity.localized()
        public class ExchangeQuantity : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换数量",
                   "兌換數量",
                   "Exchange num")
        }
        
        /// 最低金额不能大于最高金额 HL.MinimumAmountCannotBeGreater.localized()
        public class MinimumAmountCannotBeGreater : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低金额不能大于最高金额",
                   "最低金額不能大於最高金額",
                   "Minimum amount cannot be greater than maximum amount")
        }
        
        /// 最小兑换数量 HL.MinimumCountExchangeQuantity.localized()
        public class MinimumCountExchangeQuantity : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最小兑换数量",
                   "最小兌換數量",
                   "Min exchange num")
        }
        
        /// 请填写完整 HL.PleaseComplete.localized()
        public class PleaseComplete : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请填写完整",
                   "請填寫完整",
                   "Please complete")
        }
        
        /// 输入有误！ HL.IncorrectInput.localized()
        public class IncorrectInput : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("输入有误！",
                   "输入有误！",
                   "Incorrect input！")
        }
        
        /// 标签输入有误！ HL.TagIncorrectInput.localized()
        public class TagIncorrectInput : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("标签输入有误，备注只能由英文和数字组成，且长度不能超过256！",
                   "标签输入有误，备注只能由英文和数字组成，且长度不能超过256！",
                   "Incorrect input,tag is only English and Numbers, and the length should not exceed 256！")
        }
        
        /// 最小兑换数量需大于 HL.MinimumExchangeQuantityMustBeGreaterThan.localized()
        public class MinimumExchangeQuantityMustBeGreaterThan : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最小兑换数量需大于",
                   "最小兌換數量需大於",
                   "Minimum exchange quantity must be greater than")
        }
        
        /// 数量 HL.Number.localized()
        public class Number : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("数量",
                   "數量",
                   "Number")
        }
        
        /// 单笔兑换最小额度 HL.MinimumAmountOfSingleExchange.localized()
        public class MinimumAmountOfSingleExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("单笔兑换最小额度",
                   "單筆兌換最小額度",
                   "Minimum amount of single exchange")
        }
        
        /// 最小额度 HL.MinimumAmountExchange.localized()
        public class MinimumAmountExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最小额度",
                   "最小額度",
                   "Minimum amount")
        }
        
        /// 网络加载失败，点击屏幕重试 HL.NetworkLoadingFailed.localized()
        public class NetworkLoadingFailed : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("网络加载失败，点击屏幕重试",
                   "網絡加載失敗，點擊荧幕重試",
                   "Network loading failed, click the screen to try again")
        }
        
        /// 兑换7天内未完成，系统将退还剩余兑换 HL.ExchangeReminder.localized()
        public class ExchangeReminder : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换7天内未完成，系统将退还剩余兑换",
                   "兌換7天內未完成，系統將退還剩余兌換",
                   "If the exchange is not completed within 7 days, the system will return the remaining exchange")
        }
        
        /// 约兑出 HL.ContractOffer.localized()
        public class ContractOffer : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("约兑出",
                   "約兌出",
                   "Contract offer")
        }
        
        /// 已兑换 HL.Convertibility.localized()
        public class Convertibility : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已兑换",
                   "已兌換",
                   "Convertibility")
        }
        
        /// 兑换汇率 HL.ExchangeRate.localized()
        public class ExchangeRate : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换汇率",
                   "兌換匯率",
                   "ExchangeRate")
        }
        
        /// 参考汇率 HL.ReferenceRate.localized()
        public class ReferenceRate : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("参考汇率",
                   "參攷匯率",
                   "ReferenceRate")
        }
        
        /// 输入错误次数 HL.NumberOfInputErrors.localized()
        public class NumberOfInputErrors : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("输入错误次数",
                   "輸入錯誤次數",
                   "Number of input errors")
        }
        
        /// 密码错误 HL.PasswordError.localized()
        public class PasswordError : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("密码错误",
                   "密碼錯誤",
                   "Password error")
        }
        
        /// 剩余兑换 HL.SurplusExchange.localized()
        public class SurplusExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("剩余兑换",
                   "剩余兌換",
                   "Surplus exchange")
        }
        
        /// 剩余可兑换 HL.RemainingExchangeable.localized()
        public class RemainingExchangeable : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("剩余可兑换",
                   "剩餘可兌換",
                   "Remaining exchangeable")
        }
        
        /// 剩余可支付 HL.SurplusCanPay.localized()
        public class SurplusCanPay : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("剩余可兑换",
                   "剩余可兌換",
                   "Surplus exchange")
        }
        
        /// 可兑换 HL.Convertible.localized()
        public class Convertible : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("可兑换",
                   "可兌換",
                   "Convertible")
        }
        
        /// 返回 HL.Return2.localized()
        public class Return2 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("返回",
                   "返回",
                   "Return")
        }
        
        /// 支付 可用余额 HL.IWantToTradeIn.localized()
        public class IWantToTradeIn : LocalizableProtocol{
            private static var amount: String = ""
            public static func setAmount(_ a: String) -> IWantToTradeIn.Type{
                amount = a
                return IWantToTradeIn.self
            }
            public static var language: (sc: String, tc: String, en: String){
                return ("支付 (支付可用余额 \(amount))",
                    "支付 (支付可用餘額 \(amount))",
                    "Payment (Balance \(amount))")
                
            }
        }
        
        /// 已过期 HL.RedemptionExpired.localized()
        public class RedemptionExpired : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已过期",
                   "已過期",
                   "Expired")
        }
        
        /// 已完成 HL.RedemptionFinish.localized()
        public class RedemptionFinish : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已完成",
                   "已完成",
                   "Completed")
        }
        
        /// 交易已完成 HL.TransactionCompleted.localized()
        public class TransactionCompleted : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易已完成",
                   "交易已完成",
                   "Transaction completed")
        }
        
        /// 进行中 HL.RedemptionIng.localized()
        public class RedemptionIng : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("进行中",
                   "進行中",
                   "In progress")
        }
        
        /// 约兑入 HL.ApproximateExchange.localized()
        public class ApproximateExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("约兑入",
                   "約兌入",
                   "Approximate exchange")
        }
        
        /// 详情 HL.Details.localized()
        public class Details : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("详情",
                   "詳情",
                   "Details")
        }
        
        /// 筛选 HL.Screen.localized()
        public class Screen : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("筛选",
                   "篩選",
                   "Screen")
        }
        
        /// 流水明细 HL.FlowDetails.localized()
        public class FlowDetails : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("流水明细",
                   "流水明細",
                   "Flow details")
        }
        
        /// 群闪兑详情 HL.GroupFlashCashDetails.localized()
        public class GroupFlashCashDetails : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群闪兑详情",
                   "群閃兌詳情",
                   "Group flash cash details")
        }
        
        
        
        /// 兑出 HL.ExchangeOut.localized()
        public class ExchangeOut : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑出",
                   "兌出",
                   "Exchange out")
        }
        
        /// 请求超时，请再次尝试 HL.RequestTimedOutPleaseTryAgain.localized()
        public class RequestTimedOutPleaseTryAgain : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请求超时，请再次尝试",
                   "請求超時，請再次嘗試",
                   "Request timed out, please try again")
        }
        
        /// 个人 HL.Personal.localized()
        public class Personal : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("个人",
                   "個人",
                   "Personal")
        }
        
        /// 群 HL.Group1.localized()
        public class Group1 : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群",
                   "群",
                   "Group")
        }
        
        /// 本月 HL.ThisMonth.localized()
        public class ThisMonth : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("本月",
                   "本月",
                   "This month")
        }
        
        /// 时间选择器
        public class Picker{
            public class Moth: LocalizableProtocol{
                private static var index: Int = 1
                public static func set(_ i: Int) -> Moth.Type{
                    index = i
                    return self.self
                }
                
                public static var language: (sc: String, tc: String, en: String){
                    
                    let en: String = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][index]
                    
                    return ("\(index)月",
                        "\(index)月",
                        en)
                }
            }
            
            public class Year: LocalizableProtocol{
                private static var index: Int = 1
                public static func set(_ i: Int) -> Year.Type{
                    index = i
                    return self.self
                }
                public static var language: (sc: String, tc: String, en: String){
                    return ("\(index)年",
                        "\(index)年",
                        "\(index)"
                    )
                }
            }
        }
        
        /// 个人闪兑 HL.PersonalFlash.localized()
        public class PersonalFlash : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("个人闪兑",
                   "個人閃兌",
                   "Personal flash")
        }
        
        /// 发布 HL.Release.localized()
        public class Release : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发布",
                   "發布",
                   "Release")
        }
        
        /// 分享 HL.Share.localized()
        public class Share : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("分享",
                   "分享",
                   "Share")
        }
        
        /// 红包详情 HL.DetailsOfRedPackets.localized()
        public class DetailsOfRedPackets : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包详情",
                   "紅包詳情",
                   "Details of red packets")
        }
        
        
        
        
        /// 全部 HL.Whole.localized()
        public class Whole : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("全部",
                   "全部",
                   "Whole")
        }
        
        /// 查看全部 HL.ViewAll.localized()
        public class ViewAll : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("查看全部",
                   "查看全部",
                   "View all")
        }
        
        /// 转入 HL.ToChangeInto.localized()
        public class ToChangeInto : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转入",
                   "轉入",
                   "To change into")
        }
        
        /// 转出 HL.TurnOut.localized()
        public class TurnOut : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转出",
                   "轉出",
                   "Turn out")
        }
        
        
        
        /// 群成员共人 HL.GroupMembersInTotal.localized()
        public class GroupMembersInTotal : LocalizableProtocol{
            private static var count: String = ""
            public static func setCount(_ c: String) -> GroupMembersInTotal.Type{
                count = c
                return GroupMembersInTotal.self
            }
            public static var language: (sc: String, tc: String, en: String){
                return ("群成员共\(count)人",
                    "群成員共\(count)人",
                    " group members: \(count)")
            }
        }
        
        /// 红包额度额度需在 HL.TheRedEnvelopeLimitShouldBeSetAt.localized()
        public class TheRedEnvelopeLimitShouldBeSetAt : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包额度需在",
                   "紅包額度需在",
                   "The red envelope limit should be set at")
        }
        
        /// 红包数量需在 HL.TheNumberOfRedPacketsShouldBe.localized()
        public class TheNumberOfRedPacketsShouldBe : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包数量需在",
                   "紅包數量需在",
                   "The number of red packets should be")
        }
        
        /// 共个红包 HL.RedPacketsInTotal.localized()
        public class RedPacketsInTotal : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("共%@个红包",
                   "共%@個紅包",
                   "%@ red packets in total")
        }
        
        /// 目前为普通红包 HL.ItsACommonRedBagAtPresent.localized()
        public class ItsACommonRedBagAtPresent : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("目前为普通红包",
                   "目前為普通紅包",
                   "It's a common red bag at present")
        }
        
        /// 改为拼手气红包 HL.ChangeToRedEnvelopes.localized()
        public class ChangeToRedEnvelopes : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("改为拼手气红包",
                   "改為拼手氣紅包",
                   "Change to red envelopes")
        }
        
        /// 目前为拼手气红包 HL.AtPresentItsALuckyRedBag.localized()
        public class AtPresentItsALuckyRedBag : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("目前为拼手气红包",
                   "目前為拼手氣紅包",
                   "At present, it's a lucky red bag")
        }
        
        /// 改为普通红包 HL.ChangeToOrdinaryRedBag.localized()
        public class ChangeToOrdinaryRedBag : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("改为普通红包",
                   "改為普通紅包",
                   "Change to ordinary red bag")
        }
        
        /// 红包个数 HL.NumberOfRedPackets.localized()
        public class NumberOfRedPackets : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包个数",
                   "紅包個數",
                   "Number of red packets")
        }
        
        /// 个 HL.Individual.localized()
        public class Individual : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("个",
                   "個",
                   "")
        }
        
        /// 输入红包个数 HL.EnterTheNumberOfRedPackets.localized()
        public class EnterTheNumberOfRedPackets : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("输入红包个数",
                   "輸入紅包個數",
                   "Enter the number of red packets")
        }
        
        /// 的红包 HL.TheRedEnvelopeOf.localized()
        public class TheRedEnvelopeOf : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("的红包",
                   "的紅包",
                   "'s red envelope")
            
        }
        
        /// 秒后重新获取验证码 HL.TipGetTheVerificationCodeAgainInSeconds.localized()
        public class TipGetTheVerificationCodeAgainInSeconds : LocalizableProtocol{
            private static var second: Int = 0
            public static func setSecond(_ sc: Int) -> TipGetTheVerificationCodeAgainInSeconds.Type{
                second = sc
                return self.self
            }
            public static var language: (sc: String, tc: String, en: String){
                return ("\(second)秒后重新获取",
                    "\(second)秒後重新獲取",
                    "Retrieve after \(second) seconds")
            }
        }
        
        /// 两次密码不一致 HL.TwoPasswordsAreInconsistent.localized()
        public class TwoPasswordsAreInconsistent : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("两次密码不一致",
                   "兩次密碼不壹致",
                   "Two passwords are inconsistent")
        }
        
        /// 设置交易密码 HL.TipSetTransactionPassword.localized()
        public class TipSetTransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("设置交易密码",
                   "設置交易密碼",
                   "Set transaction password")
        }
        
        /// 请输入密码 HL.PleaseInputAPassword.localized()
        public class PleaseInputAPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入6位数字交易密码",
                   "請輸入6位數字交易密碼",
                   "Please enter a 6-digit transaction password")
        }
        
        /// 请在此输入密码 HL.PleaseEnterYourPasswordHere.localized()
        public class PleaseEnterYourPasswordHere : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请重复输入密码",
                   "請重複輸入密碼",
                   "Please repeat the password")
        }
        
        /// 手机号码 HL.PhoneNumber.localized()
        public class PhoneNumber : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("手机号码",
                   "手機號碼",
                   "Phone number")
        }
        
        /// 转账额度需在 HL.TheTransferAmountShouldBe.localized()
        public class TheTransferAmountShouldBe : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账额度需在",
                   "轉賬額度需在",
                   "The transfer amount should be")
        }
        
        /// 转账给 HL.TransferTo.localized()
        public class TransferTo : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账给",
                   "轉賬給",
                   "Transfer to")
        }
        
        /// 提交成功 HL.SubmitSuccessfully.localized()
        public class SubmitSuccessfully : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提交成功",
                   "提交成功",
                   "Submit successfully")
        }
        
        /// 身份证 HL.ID.localized()
        public class ID : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("身份证",
                   "身份證",
                   "ID")
        }
        
        /// 身份证正面 HL.FrontOfIDCard.localized()
        public class FrontOfIDCard : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("身份证正面",
                   "身份證正面",
                   "Front of ID card")
        }
        
        /// 身份证反面 HL.ReverseOfIDCard.localized()
        public class ReverseOfIDCard : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("身份证反面",
                   "身份證反面",
                   "Reverse of ID card")
        }
        
        /// 手持身份证正面 HL.HoldFrontOfIDCard.localized()
        public class HoldFrontOfIDCard : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("手持身份证正面",
                   "手持身份證正面",
                   "Front of ID card")
        }
        
        /// 上传身份证照片 HL.UploadIDCardPhoto.localized()
        public class UploadIDCardPhoto : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("上传身份证照片",
                   "上傳身份證照片",
                   "Upload ID card photo")
        }
        
        /// 护照 HL.Passport.localized()
        public class Passport : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("护照",
                   "護照",
                   "Passport")
        }
        
        /// 护照封面 HL.PassportCover.localized()
        public class PassportCover : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("护照封面",
                   "護照封面",
                   "Passport cover")
        }
        
        /// 个人信息面 HL.PersonalInformation.localized()
        public class PersonalInformation : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("个人信息面",
                   "個人信息面",
                   "Personal information")
        }
        
        /// 手持证件(翻页至个人信息页) HL.HoldingCertificateTurnPageToPersonalInformationPage.localized()
        public class HoldingCertificateTurnPageToPersonalInformationPage : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("手持证件(翻页至个人信息页)",
                   "手持證件(翻頁至個人信息頁)",
                   "Holding certificate (turn page to personal information page)")
        }
        
        /// 上传护照照片 HL.UploadPassportPhoto.localized()
        public class UploadPassportPhoto : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("上传护照照片",
                   "上傳護照照片",
                   "Upload passport photo")
        }
        
        /// 拍照 HL.Photograph.localized()
        public class Photograph : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("拍照",
                   "拍照",
                   "Photograph")
        }
        
        /// 相册 HL.Album.localized()
        public class Album : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("相册",
                   "相冊",
                   "Album")
        }
        
        /// 开灯 HL.TurnOnTheLight.localized()
        public class TurnOnTheLight : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("开灯",
                   "開燈",
                   "Turn on the light")
        }
        
        /// 实名认证 HL.RealNameAuthentication.localized()
        public class RealNameAuthentication : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("实名认证",
                   "實名認證",
                   "Real name authentication")
        }
        
        /// 申请认证 HL.ApplicationForCertification.localized()
        public class ApplicationForCertification : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("申请认证",
                   "申請認證",
                   "Application for certification")
        }
        
        /// 地址链接 HL.AddressLink.localized()
        public class AddressLink : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址链接",
                   "地址鏈接",
                   "Address link")
        }
        
        /// 地址链接 HL.AddressLinkTips.localized()
        public class AddressLinkTips : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址：",
                   "地址：",
                   "ADD.:")
        }
        
        /// 地址链接 HL.AddressLinkRemarkTips.localized()
        public class AddressLinkRemarkTips : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("备注编码：",
                   "备注编码：",
                   "Remark Code:")
        }
        
        /// 复制 HL.Copy.localized()
        public class Copy : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("复制",
                   "復制",
                   "Copy")
        }
        
        /// 复制成功 HL.ReplicationSuccess.localized()
        public class ReplicationSuccess : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("复制成功",
                   "復制成功",
                   "Replication success")
        }
        
        /// 提现 HL.WithdrawMoney.localized()
        public class WithdrawMoney : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现",
                   "提現",
                   "Withdraw money")
        }
        
        /// 最低提取 HL.MinimumExtraction.localized()
        public class MinimumExtraction : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低提取",
                   "最低提取",
                   "Minimum extraction")
        }
        
        /// 今日可提余额 HL.AvailableBalanceToday.localized()
        public class AvailableBalanceToday : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("今日可提余额",
                   "今日可提余额",
                   "Available balance today")
        }
        
        /// 可用: HL.Available.localized()
        public class Available : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("可用数量",
                   "可用數量",
                   "Available")
        }
        
        /// 提现数量 HL.QuantityOfWithdrawals.localized()
        public class QuantityOfWithdrawals : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现数量",
                   "提現數量",
                   "Quantity of withdrawals")
        }
        
        /// 添加 HL.AddTo.localized()
        public class AddTo : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("添加",
                   "添加",
                   "Add to")
        }
        
        /// 提现地址 HL.MoneyWithdrawalAddress.localized()
        public class MoneyWithdrawalAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现地址",
                   "提現地址",
                   "Money withdrawal address")
        }
        
        /// 添加地址 HL.AddAddress.localized()
        public class AddAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("添加地址",
                   "添加地址",
                   "Add address")
        }
        
        /// 您的个人信息将按照海螺APP隐私协议严格保密《海螺APP隐私协议》 HL.ConchAppPrivacyAgreement.localized()
        public class ConchAppPrivacyAgreement : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("您的个人信息将按照海螺APP隐私协议严格保密《海螺用户隐私政策及服务协议》",
                   "您的個人信息將按照海螺APP隱私協議嚴格保密《海螺用戶隱私政策及服務協定》",
                   "Your personal information will be strictly confidential in accordance with the HaiLuo user privacy policy and service agreement")
        }
        
        /// 您的个人信息将按照海螺APP隐私协议严格保密《海螺APP隐私协议》 HL.PrivacyAgreement.localized()
        public class PrivacyAgreement : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺APP隐私协议",
                   "海螺APP隱私協議",
                   "HaiLuo app privacy agreement")
        }
        
        /// 隐私协议 HL.SettingPrivacyAgreement.localized()
        public class SettingPrivacyAgreement : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("隐私协议",
                   "隱私協定",
                   "Privacy agreement")
        }
        
        /// 证件选择 HL.DocumentSelection.localized()
        public class DocumentSelection : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("证件选择",
                   "證件選擇",
                   "Document selection")
        }
        
        /// 证件 HL.Certificates.localized()
        public class Certificates : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("证件",
                   "證件",
                   "Certificates")
        }
        
        /// 姓名 HL.FullName.localized()
        public class FullName : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("姓名",
                   "姓名",
                   "Full name")
        }
        
        /// 真实姓名 HL.RealName.localized()
        public class RealName : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("真实姓名",
                   "真實姓名",
                   "Real name")
        }
        
        /// 请输入姓名 HL.PleaseEnterAName.localized()
        public class PleaseEnterAName : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入姓名",
                   "請輸入姓名",
                   "Please enter a name")
        }
        
        /// 证件号 HL.CertificateNumber.localized()
        public class CertificateNumber : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("证件号",
                   "證件號",
                   "Certificate number")
        }
        
        /// 请输入证件号码 HL.PleaseEnterTheIDNumber.localized()
        public class PleaseEnterTheIDNumber : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入证件号码",
                   "請輸入證件號碼",
                   "Please enter the ID number")
        }
        
        /// 身份证照片 HL.IDCardPhoto.localized()
        public class IDCardPhoto : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("身份证照片",
                   "身份證照片",
                   "ID card photo")
        }
        
        /// 正 HL.Front.localized()
        public class Front : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("正",
                   "正",
                   "Just")
        }
        
        /// 反 HL.Back.localized()
        public class Back : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("反",
                   "反",
                   "Back")
        }
        
        /// 上传手持证件照片 HL.UploadPhotosOfHoldingCertificates.localized()
        public class UploadPhotosOfHoldingCertificates : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("上传手持证件照片",
                   "上傳手持證件照片",
                   "Upload photos of holding certificates")
        }
        
        /// 协议 HL.Agreement.localized()
        public class Agreement : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("协议",
                   "協議",
                   "Agreement")
        }
        
        /// 地址记录 HL.AddressRecord.localized()
        public class AddressRecord : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址记录",
                   "地址記錄",
                   "Address record")
        }
        
        /// 简介 HL.BriefIntroduction.localized()
        public class BriefIntroduction : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("简介",
                   "簡介",
                   "Brief introduction")
        }
        
        /// 暂无简介 HL.NoBriefIntroduction.localized()
        public class NoBriefIntroduction : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("暂无简介",
                   "暫無簡介",
                   "No brief introduction")
        }
        
        /// 查看白皮书 HL.ViewWhitePaper.localized()
        public class ViewWhitePaper : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("查看白皮书",
                   "查看白皮書",
                   "View white paper")
        }
        
        /// 冻结: HL.Freeze.localized()
        public class Freeze : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("冻结",
                   "凍結",
                   "Freeze")
        }
        
        /// 可用金额 HL.AvailableAmount.localized()
        public class AvailableAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("可用金额",
                   "可用金額",
                   "Available amount")
        }
        
        /// 最低转账金额 HL.MinimumTransferAmount.localized()
        public class MinimumTransferAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低转账",
                   "最低轉賬",
                   "Minimum transfer")
        }
        
        /// 输入或长按粘贴地址 HL.EnterOrHoldThePasteAddress.localized()
        public class EnterOrHoldThePasteAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("输入或长按粘贴地址",
                   "輸入或長按粘貼地址",
                   "Enter or hold the paste address")
        }
        
        /// 地址备注 HL.AddressRemarks.localized()
        public class AddressRemarks : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址备注",
                   "地址備註",
                   "Address remarks")
        }
        
        /// 提现地址 HL.CashAddress.localized()
        public class CashAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现地址",
                   "提現地址",
                   "Cash address")
        }
        
        /// 添加提现地址 HL.AddWithdrawalAddress.localized()
        public class AddWithdrawalAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("添加提现地址",
                   "添加提現地址",
                   "Add withdrawal address")
        }
        
        /// 修改提现地址 HL.ChangeWithdrawalAddress.localized()
        public class ChangeWithdrawalAddress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("修改提现地址",
                   "修改提現地址",
                   "Change withdrawal address")
        }
        
        /// 标签 HL.Label.localized()
        public class Label : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("标签",
                   "標籤",
                   "Tag")
        }
        
        /// 编码 HL.Code.localized()
        public class Code : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("编码",
                   "編碼",
                   "Code")
        }
        
        /// 输入前请认真核对标签 HL.Label.localized()
        public class PleaseCheckTheLabel: LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("输入前请认真核对标签",
                   "輸入前請認真核對標籤",
                   "Please check the label carefully before input")
        }
        
        /// 确认修改 HL.ConfirmRevision.localized()
        public class ConfirmRevision: LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认修改",
                   "確認修改",
                   "Confirm revision")
        }
        
        /// 备注（选填） HL.RemarksOptional.localized()
        public class RemarksOptional : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("备注（选填）",
                   "備註（選填）",
                   "Remarks (optional)")
        }
        
        /// 选填 HL.Optional.localized()
        public class Optional : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("选填",
                   "選填",
                   "Optional")
        }
        
        /// 必填 HL.Required.localized()
        public class Required : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("必填" ,
                   "必填",
                   "Required")
        }
        
        /// 删除 HL.Delete.localized()
        public class Delete : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("删除",
                   "刪除",
                   "Delete")
        }
        
        /// 修改 HL.Modify.localized()
        public class Modify : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("修改",
                   "修改",
                   "Modify")
        }
        
        /// 删除成功 HL.DeleteSuccessful.localized()
        public class DeleteSuccessful : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("删除成功",
                   "刪除成功",
                   "Delete successful")
        }
        
        /// 添加成功 HL.AddSuccess.localized()
        public class AddSuccess : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("添加成功",
                   "添加成功",
                   "Add success")
        }
        
        /// 修改成功 HL.ModifiedSuccess.localized()
        public class ModifiedSuccess : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("修改成功",
                   "修改成功",
                   "Modified success")
        }
        
        /// 提现数量 HL.AmountOfMoneyRaised.localized()
        public class AmountOfMoneyRaised : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现数量",
                   "提現數量",
                   "Amount of money raised")
        }
        
        /// 地址薄 HL.AddressBook.localized()
        public class AddressBook : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址薄",
                   "地址薄",
                   "Address book")
        }
        
        /// 地址 HL.Address.localized()
        public class Address : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址",
                   "地址",
                   "ADD.")
        }
        
        /// 今日可提额度剩余： HL.TheRestOfTheAvailableLimitToday.localized()
        public class TheRestOfTheAvailableLimitToday : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("今日可提额度剩余：",
                   "今日可提額度剩余：",
                   "The rest of the available limit today:")
        }
        
        /// 手续费 HL.ServiceCharge.localized()
        public class ServiceCharge : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("手续费",
                   "手續費",
                   "Service Charge")
        }
        
        /// 费率 HL.Rate.localized()
        public class Rate : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("费率",
                   "費率",
                   "Rate")
        }
        
        /// 备注 HL.Remarks.localized()
        public class Remarks : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("备注",
                   "備註",
                   "Remarks")
        }
        
        /// 请输入备注信息 HL.PleaseEnterNotes.localized()
        public class PleaseEnterNotes : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入备注信息",
                   "請輸入備註信息",
                   "Please enter notes")
        }
        
        /// 到账数量 HL.QuantityOfArrival.localized()
        public class QuantityOfArrival : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("到账数量",
                   "到賬數量",
                   "Quantity of arrival")
        }
        
        /// 未获取到有效地址 HL.NoValidAddressObtained.localized()
        public class NoValidAddressObtained : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("未获取到有效地址",
                   "未獲取到有效地址",
                   "No valid address obtained")
        }
        
        /// 没有可用币种 HL.NoCurrencyAvailable.localized()
        public class NoCurrencyAvailable : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("没有可用币种",
                   "沒有可用幣種",
                   "No currency available")
        }
        
        /// 实名认证审核中 HL.RealNameVerificationInProgress.localized()
        public class RealNameVerificationInProgress : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("实名认证审核中",
                   "實名認證審核中",
                   "Real name verification in progress")
        }
        
        /// 实名认证失败 HL.RealNameAuthenticationFailed.localized()
        public class RealNameAuthenticationFailed : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("实名认证失败",
                   "實名認證失敗",
                   "Real name authentication failed")
        }
        
        /// 未实名认证 HL.NoRealNameAuthentication.localized()
        public class NoRealNameAuthentication : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("未实名认证",
                   "未實名認證",
                   "No real name authentication")
        }
        
        /// 添加币种 HL.AddCurrencies.localized()
        public class AddCurrencies : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("添加币种",
                   "添加幣種",
                   "Add currencies")
        }
        
        /// 总资产折合(USDT) HL.TotalAssetsConverted.localized()
        public class TotalAssetsConverted : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("总资产折合(USDT)",
                   "總資產折合（USDT）",
                   "Total assets converted (usdt)")
        }
        
        /// 充值 HL.Recharge.localized()
        public class Recharge : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("充值",
                   "充值",
                   "Recharge")
        }
        
        /// 提现申请成功 HL.CurrencyWithdrawalApplicationSucceeded.localized()
        public class CurrencyWithdrawalApplicationSucceeded : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现申请成功",
                   "提現申請成功",
                   "Currency withdrawal application succeeded")
        }
        
        /// 请输入有效提现金额 HL.PleaseEnterAValidWithdrawalAmount.localized()
        public class PleaseEnterAValidWithdrawalAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入有效提现金额",
                   "請輸入有效提現金額",
                   "Please enter a valid withdrawal amount")
        }
        
        /// 使用内置代理 HL.UseBuiltinAgent.localized()
        public class UseBuiltinAgent : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("使用内置代理",
                   "使用內置代理",
                   "Use built-in agent")
        }
        
        /// 未认证 HL.Uncertified.localized()
        public class Uncertified : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("未认证",
                   "未認證",
                   "Uncertified")
        }
        
        /// 已认证 HL.Certified.localized()
        public class Certified : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已认证",
                   "已認證",
                   "Certified")
        }
        
        /// 认证失败 HL.AuthenticationFailed.localized()
        public class AuthenticationFailed : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("认证失败",
                   "認證失敗",
                   "Authentication failed")
        }
        
        /// 未设置 HL.NotSetUp.localized()
        public class NotSetUp : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("未设置",
                   "未設置",
                   "Not set up")
        }
        
        /// 更改 HL.Change.localized()
        public class Change : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("更改",
                   "更改",
                   "Change")
        }
        
        /// 账户密保 HL.AccountSecurity.localized()
        public class AccountSecurity : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("账户密保",
                   "賬戶密保",
                   "Account security")
        }
        
        /// 邀请好友 HL.InviteNewUser.localized()
        public class InviteNewUser : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("邀请好友",
                   "邀請好友",
                   "Invite friends")
        }
        
        /// 代理 HL.Agent.localized()
        public class Agent : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("代理",
                   "代理",
                   "Proxy")
        }
        
        /// 切换代理 HL.SwitchProxy.localized()
        public class SwitchProxy : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("切换代理",
                   "切換代理",
                   "Switch proxy")
        }
        
        /// 切换 HL.Switch.localized()
        public class Switch : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("切换",
                   "切換",
                   "Switch")
        }
        
        /// 海螺账号登录 HL.HaiLuoAccountLogin.localized()
        public class HaiLuoAccountLogin : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺账号登录",
                   "海螺帳號登入",
                   "HaiLuo account login")
        }
        
        /// 创建群组 HL.CreateGroup.localized()
        public class CreateGroup : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("创建群组",
                   "創建群組",
                   "Create Group")
        }
        
        /// 添加好友 HL.AddFriends.localized()
        public class AddFriends : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("添加好友",
                   "添加好友",
                   "Add friends")
        }
        
        /// 创建频道 HL.CreateChannel.localized()
        public class CreateChannel : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("创建频道",
                   "創建頻道",
                   "Create channel")
        }
        
        /// 频道绑定的群总人数 HL.TotalNumberOfGroupsBoundByChannel.localized()
        public class TotalNumberOfGroupsBoundByChannel : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("频道绑定的群总人数",
                   "頻道綁定的群總人數",
                   "Total number of groups bound by channel")
        }
        
        public class RichScan : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("扫  一  扫",
                   "掃  一  掃",
                   "Scan QR Code")
        }
        
        /// 好的 HL.Well.localized()
        public class Well : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("好的",
                   "好的",
                   "Well")
        }
        
        /// 操作异常 HL.AbnormalOperation.localized()
        public class AbnormalOperation : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("操作异常",
                   "操作異常",
                   "Abnormal operation")
        }
        
        /// 请输入交易密码 HL.PleaseEnterTheTransactionPassword.localized()
        public class PleaseEnterTheTransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入交易密码",
                   "請輸入交易密碼",
                   "Please enter the transaction password")
        }
        
        /// 实际到账 HL.ActualArrival.localized()
        public class ActualArrival : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("实际到账",
                   "實際到賬",
                   "Actual arrival")
        }
        
        /// 红包已领取 HL.RedBagHasBeenReceived.localized()
        public class RedBagHasBeenReceived : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包已领取",
                   "紅包已領取",
                   "Red bag has been received")
        }
        
        /// 红包未领取 HL.RedPacketNotReceived.localized()
        public class RedPacketNotReceived : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包未领取",
                   "紅包未領取",
                   "Red packet not received")
        }
        
        /// 资讯 HL.Information.localized()
        public class Information : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("资讯",
                   "資訊",
                   "Information")
        }
        
        /// 精选 HL.Selected.localized()
        public class Selected : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("精选",
                   "精選",
                   "Selected")
        }
        
        /// 快讯 HL.NewsFlash.localized()
        public class NewsFlash : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("快讯",
                   "快訊",
                   "News flash")
        }
        
        /// 应用中心 HL.ApplicationCenter.localized()
        public class ApplicationCenter : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("应用中心",
                   "應用中心",
                   "Application Center")
        }
        
        /// 海螺官方频道 HL.ConchOfficialChannel.localized()
        public class ConchOfficialChannel : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺官方频道",
                   "海螺官方頻道",
                   "Hailuo official channel")
        }
        
        /// 设置成功 HL.SetUpSuccessfully.localized()
        public class SetUpSuccessfully : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("设置成功",
                   "設置成功",
                   "Set up successfully")
        }
        
        /// 发送成功 HL.SendSuccessfully.localized()
        public class SendSuccessfully : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发送成功",
                   "發送成功",
                   "Send successfully")
        }
        
        /// 更绑成功
        public class MoreSuccessful : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("更绑成功",
                   "更綁成功",
                   "Replace binding successful")
        }
        
        /// 交易密码未设置 HL.TransactionPasswordNotSet.localized()
        public class TransactionPasswordNotSet : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易密码未设置",
                   "交易密碼未設置",
                   "Transaction password not set")
        }
        
        /// 兑换币种不可相同 HL.ExchangeCurrencyCannotBeTheSame.localized()
        public class ExchangeCurrencyCannotBeTheSame : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换币种不可相同",
                   "兌換幣種不可相同",
                   "Exchange currency cannot be the same")
        }
        
        /// 最低发送金额 HL.MinimumSendingAmount.localized()
        public class MinimumSendingAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低发送",
                   "最低發送",
                   "Minimum sending")
        }
        
        /// 最低兑换金额 HL.MinimumExchangeAmount.localized()
        public class MinimumExchangeAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低兑换",
                   "最低兌換",
                   "Minimum exchange")
        }
        
        /// 最低提现金额 HL.MinimumWithdrawalAmount.localized()
        public class MinimumWithdrawalAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低提现",
                   "最低提現",
                   "Minimum withdrawal")
        }
        
        /// 确认收款 HL.ConfirmReceipt.localized()
        public class ConfirmReceipt : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认收款",
                   "確認收款",
                   "Confirm receipt")
        }
        
        /// 的转账 HL.TransferOf.localized()
        public class TransferOf : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("的转账",
                   "的轉賬",
                   "Transfer of")
        }
        
        /// 等待对方收款 HL.WaitingForReceiving.localized()
        public class WaitingForReceiving : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("等待对方收款",
                   "等待對方收款",
                   "Waiting for receiving")
        }
        
        /// 已收款 HL.Receivable.localized()
        public class Receivable : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已收款",
                   "已收款",
                   "Receivable")
        }
        
        /// 您还未设置交易密码，请前往设置 HL.SetTransactionPassword.localized()
        public class SetTransactionPassword : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("您还未设置交易密码，请前往设置",
                   "您還未設置交易密碼，請前往設置",
                   "You have not set the transaction password, please go to set")
        }
        
        /// 查看领取详情 HL.ViewClaimDetails.localized()
        public class ViewClaimDetails : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("查看领取详情",
                   "查看領取詳情",
                   "View claim details")
        }
        
        /// 地址修改 HL.AddressModification.localized()
        public class AddressModification : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址修改",
                   "地址修改",
                   "Modify address")
        }
        
        /// 地址添加 HL.AddressAdd.localized()
        public class AddressAdd : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("地址添加",
                   "地址添加",
                   "Add Address")
        }
        
        /// 当前币种地址为空，赶紧添加吧 HL.CurrentCurrencyAddressIsEmpty.localized()
        public class CurrentCurrencyAddressIsEmpty : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("当前币种地址为空，赶紧添加吧",
                   "當前幣種地址為空，趕緊添加吧",
                   "The current currency address is empty. Add it now")
        }
        
        /// 领取红包 HL.ReceiveARedEnvelope.localized()
        public class ReceiveARedEnvelope : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("领取红包",
                   "領取紅包",
                   "Receive gift")
        }
        
        /// 红包退回 HL.ReturnOfRedEnvelope.localized()
        public class ReturnOfRedEnvelope : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包退回",
                   "紅包退回",
                   "Gift return")
        }
        
        /// 闪兑退回 HL.FlashBack.localized()
        public class FlashBack : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("闪兑退回",
                   "閃兌退回",
                   "Flash exchange return")
        }
        
        /// 支出 HL.Expenditure.localized()
        public class Expenditure : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支出",
                   "支出",
                   "Expenditure")
        }
        
        /// 收入 HL.Revenue.localized()
        public class Revenue : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("收入",
                   "收入",
                   "Revenue")
        }
        
        /// 解冻 HL.Unfreeze.localized()
        public class Unfreeze : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("解冻",
                   "解凍",
                   "Unfreeze")
        }
        
        
        /// 类型 HL.TypeKey.localized()
        public class TypeKey : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("类型",
                   "類型",
                   "Type")
        }
        
        /// 时间 HL.Time.localized()
        public class Time : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("时间",
                   "時間",
                   "Time")
        }
        
        /// 订单编号 HL.OrderNumber.localized()
        public class OrderNumber : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("订单编号",
                   "訂單編號",
                   "Order ID")
        }
        
        /// 可用余额 HL.AvailableBalance.localized()
        public class AvailableBalance : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("可用余额",
                   "可用余額",
                   "Available balance")
        }
        
        /// 交易成功 HL.SuccessfulTrade.localized()
        public class SuccessfulTrade : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易成功",
                   "交易成功",
                   "Successful trade")
        }
        
        /// 说明 HL.Explain.localized()
        public class Explain : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("说明",
                   "說明",
                   "Explain")
        }
        
        /// 快捷筛选 HL.QuickScreening.localized()
        public class QuickScreening : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("类型快捷筛选",
                   "类型快捷篩選",
                   "Quick screening")
        }
        
        /// 方向筛选 HL.DirectionSelection.localized()
        public class DirectionSelection : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("方向筛选",
                   "方向篩選",
                   "Income or expenditure")
        }
        
        /// 金额 HL.AmountOfMoney.localized()
        public class AmountOfMoney : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("金额",
                   "金額",
                   "Amount")
        }
        
        /// 最高金额 HL.MaximumSum.localized()
        public class MaximumSum : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最高金额",
                   "最高金額",
                   "Maximum amount")
        }
        
        /// 最低金额 HL.MinimumAmount.localized()
        public class MinimumAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("最低金额",
                   "最低金額",
                   "Minimum amount")
        }
        
        /// 重置 HL.Reset.localized()
        public class Reset : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("重置",
                   "重置",
                   "Reset")
        }
        
        /// 所有 HL.All.localized()
        public class All : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("所有",
                   "所有",
                   "All")
        }
        
        /// 交易人 HL.Trader.localized()
        public class Trader : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("交易人",
                   "交易人",
                   "Trader")
        }
        
        /// 发布群 HL.PublishingGroup.localized()
        public class PublishingGroup : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发布群",
                   "發布群",
                   "Publishing Group")
        }
        
        /// 兑换人 HL.Changer.localized()
        public class Changer : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换人",
                   "兌換人",
                   "Changer")
        }
        
        /// 兑换群 HL.ExchangeGroup.localized()
        public class ExchangeGroup : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换群",
                   "兌換群",
                   "Exchange group")
        }
        
        /// 退回数量 HL.QuantityReturned.localized()
        public class QuantityReturned : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("退回数量",
                   "退回數量",
                   "Quantity returned")
        }
        
        /// 兑换时间 HL.ExchangeTime.localized()
        public class ExchangeTime : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换时间",
                   "兌換時間",
                   "Exchange time")
        }
        
        /// 红包状态 HL.RedEnvelopeState.localized()
        public class RedEnvelopeState : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包状态",
                   "紅包狀態",
                   "Gift status")
        }
        
        /// 红包类型 HL.RedEnvelopeType.localized()
        public class RedEnvelopeType : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("红包类型",
                   "紅包類型",
                   "Gift type")
        }
        
        /// 群名称 HL.GroupName.localized()
        public class GroupName : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("群名称",
                   "群名稱",
                   "Group")
        }
        
        /// 领取合计 HL.TotalCollection.localized()
        public class TotalCollection : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("领取合计",
                   "領取合計",
                   "Total collection")
        }
        
        /// 发送人 HL.Sender.localized()
        public class Sender : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发送人",
                   "發送人",
                   "Sender")
        }
        
        /// 领取人 HL.Receiver.localized()
        public class Receiver : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("领取人",
                   "領取人",
                   "Receiver")
        }
        
        /// 领取时间 HL.TimeToCollect.localized()
        public class TimeToCollect : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("领取时间",
                   "領取時間",
                   "Time")
        }
        
        /// 支付时间 HL.PaymentTime.localized()
        public class PaymentTime : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支付时间",
                   "支付時間",
                   "Payment time")
        }
        
        /// 退回时间 HL.ReturnTime.localized()
        public class ReturnTime : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("退回时间",
                   "退回時間",
                   "Return time")
        }
        
        /// 转账状态 HL.TransferStatus.localized()
        public class TransferStatus : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账状态",
                   "轉賬狀態",
                   "Transfer status")
        }
        
        /// 转账时间 HL.TransferTime.localized()
        public class TransferTime : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("转账时间",
                   "轉賬時間",
                   "Transfer time")
        }
        
        /// 提取状态 HL.ExtractionState.localized()
        public class ExtractionState : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提取状态",
                   "提取狀態",
                   "Currency Withdrawing status")
        }
        
        /// 提现时间 HL.MoneyRaisingTime.localized()
        public class MoneyRaisingTime : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("提现时间",
                   "提現時間",
                   "Currency Withdrawing time")
        }
        
        /// 拒绝原因 HL.ReasonsForRefusal.localized()
        public class ReasonsForRefusal : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("拒绝原因",
                   "拒絕原因",
                   "Refuse reason")
        }
        
        /// 取消 HL.Cancel.localized()
        public class Cancel : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("取消",
                   "取消",
                   "Cancel")
        }
        
        /// 兑出数量 HL.QuantityDelivered.localized()
        public class QuantityDelivered : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑出数量",
                   "兌出數量",
                   "Quantity delivered")
        }
        
        /// 兑入数量 HL.QuantityAdded.localized()
        public class QuantityAdded : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑入数量",
                   "兌入數量",
                   "Quantity added")
        }
        
        /// 支付数量 HL.QuantityOfPayment.localized()
        public class QuantityOfPayment : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支付数量",
                   "支付數量",
                   "QuantityOfPayment")
        }
        
        /// 约支付 HL.ApproximatePayment.localized()
        public class ApproximatePayment : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("约支付",
                   "約支付",
                   "Approximate payment")
        }
        
        /// 支付 HL.Payment.localized()
        public class Payment : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支付",
                   "支付",
                   "Payment")
        }
        
        /// 支付币种可用余额 HL.AvailableBalanceInPayment.localized()
        public class AvailableBalanceInPayment : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支付可用余额",
                   "支付可用餘額",
                   "Available balance in payment")
        }
        
        /// 已撤销 HL.ExchangeCancelled.localized()
        public class ExchangeCancelled : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已撤销",
                   "已撤銷",
                   "Cancelled")
        }
        
        /// 闪兑状态 HL.ExchangeState.localized()
        public class ExchangeState : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("闪兑状态",
                   "閃兌狀態",
                   "Exchange state")
        }
        
        /// 已撤销 HL.Rescinded.localized()
        public class Rescinded : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已撤销",
                   "已撤銷",
                   "Rescinded")
        }
        
        /// 已退回 HL.HasBeenReturned.localized()
        public class HasBeenReturned : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已退回",
                   "已退回",
                   "Refund")
        }
        
        /// 剩余红包 HL.SurplusGift.localized()
        public class SurplusGift : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("已领取：%@个",
                   "已領取：%@個",
                   "Received：%@")
        }
        
        ///领取数量  HL.NumberOfRecipients.localized()
        public class NumberOfRecipients : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("领取数量",
                   "領取數量",
                   "Number of recipients")
        }
        
        /// 支付额度需在 HL.PaymentAmountShouldBeIn.localized()
        public class PaymentAmountShouldBeIn : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("支付额度需在%@-%@",
                   "支付額度需在%@-%@",
                   "The payment amount should be in %@ - %@")
        }
        
        /// 兑换额度需在 HL.ExchangeAmountShouldBeIn.localized()
        public class ExchangeAmountShouldBeIn : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("兑换额度需在%@-%@",
                   "兌換額度需在%@-%@",
                   "The exchange limit should be in %@ - %@")
        }
        
        /// 请输入金额 HL.PleaseEnterTheAmount.localized()
        public class PleaseEnterTheAmount : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请输入金额",
                   "請輸入金額",
                   "Please enter the amount")
        }
        
        /// 没有搜索结果 HL.NoSearchResults.localized()
        public class NoSearchResults : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("没有搜索结果",
                   "沒有搜索結果",
                   "No search results")
        }
        
        /// 网络不可用 HL.NetworkUnavailable.localized()
        public class NetworkUnavailable : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("网络不可用",
                   "網絡不可用",
                   "Network unavailable")
        }
        
        /// 系统异常 HL.SystemException.localized()
        public class SystemException : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("系统异常",
                   "系統异常",
                   "System exception")
        }
        
        /// 请求失败 HL.RequestWasAborted.localized()
        public class RequestWasAborted : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("请求失败",
                   "請求失敗",
                   "Request was aborted")
        }
        
        /// 请求失败 HL.BotAborted.localized()
        public class BotAborted : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("根据 App Store 审核指南，在海螺中不可用",
                   "根据 App Store 审核指南，在海螺中不可用",
                   "Not available in conch, according to App Store review guidelines")
        }
        
        /// 翻译 HL.TranslateTitle.localized()
        public class TranslateTitle : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("翻译",
                   "翻译",
                   "Translate")
        }
        
        /// 撤销翻译 HL.UndoTranslateTitle.localized()
        public class UndoTranslateTitle : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("撤销翻译",
                   "撤销翻译",
                   "Undo Translate")
        }
        
        /// 海螺翻译 HL.TranslateError.localized()
        public class TranslateError : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("翻译失败，请重试",
                   "翻译失败，请重试",
                   "Translate fail,Please try again")
        }
        
        /// 海螺翻译 HL.TranslateTips.localized()
        public class TranslateTips : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("海螺翻译",
                   "海螺翻译",
                   "Conch translation")
        }
        
        /// 闪兑广场 HL.ExchangeSquare.localized()
        public class ExchangeSquare : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("闪兑广场",
                   "閃兌廣場",
                   "Exchange square")
        }
        
        /// 广场订单 HL.SquareOrder.localized()
        public class SquareOrder : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("广场订单",
                   "廣場訂單",
                   "Square order")
        }
        
        /// 我的订单 HL.MyOrder.localized()
        public class MyOrder : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我的订单",
                   "我的訂單",
                   "My order")
        }
        
        /// 发布到闪对广场增加曝光率，更快达成兑换 HL.ReleaseToSquareTip.localized()
        public class ReleaseToSquareTip : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发布到闪对广场增加曝光率，更快达成兑换",
                   "發佈到閃對廣場新增曝光率，更快達成兌換",
                   "Release to square to increase exposure and exchange faster")
        }
        
        /// 我支付的 HL.IPaidFor.localized()
        public class IPaidFor : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我支付的",
                   "我支付的",
                   "I paid for")
        }
        
        /// 我要兑换 HL.IWantExchange.localized()
        public class IWantExchange : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("我要兑换",
                   "我要兌換",
                   "I want exchange")
        }
        
        /// 需要您支付 HL.YouNeedPay.localized()
        public class YouNeedPay : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("需要您支付",
                   "需要您支付",
                   "You need pay")
        }
        
        /// 发起方支付 HL.SponsorPayment.localized()
        public class SponsorPayment : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("发起方支付",
                   "需要您支付",
                   "Sponsor payment")
        }
        /// 确认发布 HL.ConfirmRelease.localized()
        public class ConfirmRelease : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("确认发布",
                   "確認發佈",
                   "Confirm release")
        }
        
        /// 查看 HL.See.localized()
        public class See : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("查看",
                   "查看",
                   "See")
        }
        
        /// 进入 HL.GetInto.localized()
        public class GetInto : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("进入",
                   "進入",
                   "Get into")
        }
        
        /// 我的二维码 HL.MyQRCodeTitle.localized()
        public class MyQRCodeTitle : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("二维码名片",
                   "二維碼名片",
                   "My QR code")
        }
        
        /// 群组二维码 HL.GroupQRCodeTitle.localized()
        public class GroupQRCodeTitle : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("群组二维码",
                   "群組二維碼",
                   "Group QR code")
        }
        
        /// 保存二维码 HL.SaveQRCode.localized()
        public class SaveQRCode : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("保存二维码",
                   "保存二維碼",
                   "Save QR code")
        }
        
        /// 扫一扫 添加我为好友
        public class MyQRCodeMarkedWords : LocalizableProtocol{
            public static var language: (sc: String, tc: String, en: String)
                = ("扫一扫 添加我为好友",
                   "掃一掃 添加我為好友",
                   "Scan add me as friend.")
        }
        
        /// 扫一扫 马上加入组群
        public class GroupQRCodeMarkedWords : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("扫一扫 马上加入组群",
                   "掃一掃 馬上加入群組",
                   "Scan joins the group immediately.")
        }
        
        public class PeopleNearby : LocalizableProtocol {
            public static var language: (sc: String, tc: String, en: String)
                = ("附近的人",
                   "附近的人",
                   "People nearby")
        }
    }
}
