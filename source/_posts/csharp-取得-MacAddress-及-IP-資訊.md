---
title: csharp 取得 MacAddress 及 IP 資訊
date: 2021-01-12 21:03:00
tags: csharp
---
&nbsp;
<!-- more -->

每隔個N年莫名其妙都會遇到這個問題，筆記一下首先感恩 [sharppcap](https://github.com/chmorgan/sharppcap) 這個套件，無腦用 nuget 安裝完即可
開心的複製貼上 [example](https://github.com/chmorgan/sharppcap/blob/master/Examples/Example1.IfList/Example1.IfList.cs) 馬上就 gg 了
炸了這個 error `wpcap.dll was not found`
查了下才發先原來要安裝 [Win10Pcap](http://www.win10pcap.org/download/)
接著無腦 coding , 可以看他的 [example](https://github.com/chmorgan/sharppcap/blob/master/Examples/Example2.ArpResolve/Program.cs)
比較雷的是要用 Open 去打開，有點麻煩 @@!
## full example
``` csharp
using SharpPcap;
using SharpPcap.LibPcap;
using SharpPcap.Npcap;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleAppFetchMacAddress
{
    public class Program
    {
        /// <summary>
        /// Obtaining the device list
        /// </summary>
        public static void Main(string[] args)
        {
            // Print SharpPcap version
            string ver = SharpPcap.Version.VersionString;
            Console.WriteLine( "SharpPcap {0}, Example1.IfList.cs", ver );

            // Retrieve the device list
            var devices = CaptureDeviceList.Instance;

            // If no devices were found print an error
            if (devices.Count < 1)
            {
                Console.WriteLine( "這台機器上沒有任何設備" );
                return;
            }

            Console.WriteLine( "\nThe following devices are available on this machine:" );
            Console.WriteLine( "----------------------------------------------------\n" );

            /* Scan the list printing every entry */
            foreach (LibPcapLiveDevice dev in devices)
            {
                //注意這個要打開不然沒辦法跑客製化的 code
                dev.Open( );

                //客製化
                Console.WriteLine( $@"Name:{dev.Name}" );
                Console.WriteLine( $@"MacAddress:{dev.MacAddress}" );
                Console.WriteLine( $@"Description:{dev.Description}" );
                Console.WriteLine( $@"FriendlyName:{ dev.Interface.FriendlyName }" );

                //IP位置
                foreach (var item in dev.Addresses)
                {
                    string input = item.Addr.ToString( );

                    IPAddress address;
                    if (IPAddress.TryParse( input, out address ))
                    {
                        switch (address.AddressFamily)
                        {
                            case System.Net.Sockets.AddressFamily.InterNetwork:
                                Console.WriteLine( $"IP位置)IPV4:{item.Addr.ToString( )}" );
                                break;
                            case System.Net.Sockets.AddressFamily.InterNetworkV6:
                                Console.WriteLine( $"IP位置)IPV6:{item.Addr.ToString( )}" );
                                break;
                            default:
                                Console.WriteLine( $"IP位置)其他:{item.Addr.ToString( )}" );
                                break;
                        }
                    }
                }

                //預設閘道
                foreach (var item in dev.Interface.GatewayAddresses)
                {
                    switch (item.AddressFamily)
                    {
                        case System.Net.Sockets.AddressFamily.InterNetwork:
                            Console.WriteLine( $"預設閘道)IPV4:{item.ToString( )}" );
                            break;
                        case System.Net.Sockets.AddressFamily.InterNetworkV6:
                            Console.WriteLine( $"預設閘道)IPV6:{item.ToString( )}" );
                            break;
                        default:
                            Console.WriteLine( $"預設閘道)其他:{item.ToString( )}" );
                            break;
                    }
                }

                //直接開這個就可以得全部訊息
                //Console.WriteLine( "{0}\n", dev.ToString( ) );

                //記得關閉資源
                dev.Close( );

                Console.WriteLine( "----------------------------------------------------" );
            }

            Console.Write( "按下 Enter 離開..." );
            Console.ReadLine( );
        }
    }
}

```
