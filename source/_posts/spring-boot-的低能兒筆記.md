---
title: spring boot 的低能兒筆記
date: 2021-04-11 12:45:23
tags:
---
&nbsp;
<!-- more -->

### 設定 java
因為三不五時又會遇到討厭的 java , 為了了解其生態系 , 不得已只好花點時間看看 , 不然每次都雞同鴨講
第一步先安裝 JDK 可以裝 [Oracle 的版本](https://www.oracle.com/tw/java/technologies/javase/javase-jdk8-downloads.html) or OpenJDK , 現在有新選擇 [M$ 也有 OpenJDK 了](https://www.microsoft.com/openjdk)
接著新增以下環境變數
變數名稱 `JAVA_HOME` 變數值 `C:\Program Files\Java\jdk1.8.0_151`
變數名稱 `CLASSPATH` 變數值 `.;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar`
變數名稱 `PATH` 變數值 `%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin`
接著 `cmd` `java -version` `javac -version` 看看有無成功輸出
然後下載類似 `Nuget` 的套件管理工具 [Maven](https://maven.apache.org/)
變數名稱 `MAVEN_HOME` 變數值 `C:\apache-maven-3.5.2` 並在 `PATH` 後面加上 `%MAVEN_HOME%\bin\`
接著一樣敲 `cmd` `mvn -v` 看看有無成功輸出

### powershell 中文 build java 亂碼問題
無意中發現 powershell 呼叫 java 亂碼的問題 , [參考自此](https://stackoverflow.com/questions/44208347/unable-to-set-correct-encoding-in-powershell)
新增環境變數 `JAVA_TOOL_OPTIONS` `-Dfile.encoding=utf-8`
```
echo "public class HelloWorld { public static void main(String[] args){ System.out.println(`"Helloworld`" ); } }" | Out-File -Encoding ascii HelloWorld.java
```

這裡如 Encoding 設定 utf8 會送你加了 BOM 的
有夠無言 javac 編譯又不會讓你過 , 寫個簡單的 echo 一堆問題有夠難用
如果真的要印中文無 BOM 最好參考這篇老外[解法](https://stackoverflow.com/questions/5596982/using-powershell-to-write-a-file-in-utf-8-without-the-bom) , 我就懶得多寫了
```
java HelloWorld
#Picked up JAVA_TOOL_OPTIONS: -Dfile.encoding=utf-8
#Helloworld
```

### 設定 intellij
接著安裝 Intellij
老樣子安裝 [IdeaVim](https://plugins.jetbrains.com/plugin/index?xmlId=IdeaVIM) 因為之前用 `Android Studio` config 過了所以直接[拿以前的來抄](https://weber87na.github.io/2021/02/21/Android-Studio-vim-mode/)
接著安裝 `Spring Assistant` & `JPA Support` 這2個 plugin `File` => `Settings` => `Plugins` => `Spring Assistant` `JPA Support`
然後設定 Maven 在 `File` => `Settings` => `Build,Execution,Deployment` => `Maven home path` 看看要不要自己手動設定 , 這邊先用預設
建立 Spring 專案 `File` => `New` => `Project` => `Spring Assistant` => `Java Version 8` => `Next` => `Web` => `Spring Web` 靜待片刻

### choco 安裝 java
用 choco 安裝 openjdk8 , 可以[參考此連結](https://community.chocolatey.org/packages/jdk8#install)
```
choco install openjdk8
```
從 powershell 下載訊息中可以看到基本上也是從 [adoptopenjdk](https://adoptopenjdk.net/?variant=openjdk8&jvmVariant=hotspot) 下載的
https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u282-b08/OpenJDK8U-jdk_x64_windows_8u282b08.zip
下載後會幫你加 `JAVA_HOME` 在以下路徑 `C:\Program Files\OpenJDK\openjdk-8u282-b08`
`PATH` 也會幫你自動加上去 `C:\Program Files\OpenJDK\openjdk-8u282-b08\bin`

安裝 maven
```
choco install maven
```
安裝完可以看到設定了 `M2_HOME` 在以下路徑 `C:\ProgramData\chocolatey\lib\maven\apache-maven-3.8.1`
以及 `PATH` 追加了 `%M2_HOME%\bin`
有點納悶不是應該叫做 `MAVEN_HOME` 嗎? [參考老外] 原來 Maven 1 是用 `MAVEN_HOME` Maven 2 則用 `M2_HOME` 其實沒差
感覺用 choco 安裝更無腦

今天還遇到個之前沒遇過的低能問題 , 就是無法在 windows 底下新增開頭有點 `.` 的特殊檔案 , 搞了半天沒辦法用 `.ideavimrc`
google 看到老外說用 notepad++ 選另存新檔 , file type 選擇 all 就可以了

### 在 intellij 安裝 
主要參考這篇[官方](https://www.jetbrains.com/help/idea/convert-a-regular-project-into-a-maven-project.html)
在 `pom.xml` 內加入類似如下片段即可
```
<dependencies>
	<dependency>
		<groupId>io.github.fanyong920</groupId>
		<artifactId>jvppeteer</artifactId>
		<version>1.1.3</version>
	</dependency>
</dependencies>
```

### 牛刀小試 jdbcTemplate
看書上照著做沒多久就陣亡了 , 書上的範例是 mysql 懶得安裝 mysql 直接用現成的 M$
首先在 `application.properties` 底下增加連線訊息
```
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=test
spring.datasource.username=sa
spring.datasource.password=yourpassword
spring.datasource.driverClassName=com.microsoft.sqlserver.jdbc.SQLServerDriver
spring.datasource.initialize=true
```
特別注意這句 `spring.datasource.driverClassName=com.microsoft.sqlserver.jdbc.SQLServerDriver` 這句是低能關鍵 , 一開始依照其他低能老外寫的怎麼 try 都掛點 , 後來是看到[這篇](https://springframework.guru/configuring-spring-boot-for-microsoft-sql-server/)佛心老外才成功
另外 pom.xml 要增加以下相依
```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-jdbc</artifactId>
</dependency>
<dependency>
	<groupId>org.projectlombok</groupId>
	<artifactId>lombok</artifactId>
</dependency>
<dependency>
	<groupId>com.microsoft.sqlserver</groupId>
	<artifactId>mssql-jdbc</artifactId>
	<version>9.2.1.jre8</version>
</dependency>
```
老樣子可以[參考微軟天書](https://docs.microsoft.com/zh-tw/sql/connect/jdbc/system-requirements-for-the-jdbc-driver?view=sql-server-ver15) , 這邊會炸大概都是 jre 的版本寫錯 , 我是用 java 8 , 所以要進行相應的調整 , 才剛開始搞就發現 , spring 的 config 超級難設定 , 對新手真不友善

接著加個 `Customer` 類別跟 `CustomerController` 類別
特別注意這邊標示 Data 的話起先 intellij 會認不得 , 只要無腦按 `Add CLASSPATH` 它會自動加入 `lombok` 到 `pom`

```
package com.example.demo;


import lombok.Data;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;

@Data
public class Customer implements RowMapper<Customer> {
	private  int id;
	private  String firstName;
	private String lastName;
	@Override
		public Customer mapRow(ResultSet resultSet, int i) throws SQLException {
			Customer customer = new Customer();
			customer.setId(resultSet.getInt("Id"));
			customer.setFirstName(resultSet.getString("FirstName"));
			customer.setLastName(resultSet.getString("LastName"));
			return customer;
		}
}
```

因為沒寫過 spring 所以特別筆記一下 Autowired 這個是讓 DI 自動注入 , 所以無腦標示以後就可以用了
controller 的部分寫起來有點像 .net core
撈資料程式碼寫起來有點像 `Dapper` or `ADO.NET` 以一個廢物第一天寫可以搞起來算是不錯了!
```
package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("customer")
public class CustomerController {
	@Autowired
		private JdbcTemplate jdbcTemplate;

	@GetMapping("list")
		public List<Customer> list() throws Exception{
			String sql = "SELECT Id , FirstName , LastName FROM Customers";
			List<Customer> result = jdbcTemplate.query(sql,new BeanPropertyRowMapper<Customer>(Customer.class));
			return  result;
		}
}
```
最後執行 `http://127.0.0.1:8080/customer/list` 就能得到 Customers 資料表內的 json 資料了 , 感動!

### 牛刀小試 JPA
首先加入 pom 依賴
```
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

```
JPA 跟 entity framework 一樣難搞 , 通常在 M$ 荼毒之下會用大寫駝峰命資料庫欄位 `FirstName`  但 JPA 會解析成 `first_name` , [參考老外](https://stackoverflow.com/questions/25283198/spring-boot-jpa-column-name-annotation-ignored)所以要很變態的在 annotation 設定這樣 `@Column(name = "firstname")`
不過有有一勞永逸的方法就是直接在 properties 裡面直接設定以下內容即可
```
spring.jpa.hibernate.naming.implicit-strategy=org.hibernate.boot.model.naming.ImplicitNamingStrategyLegacyJpaImpl
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
```

```
package com.example.demo;

import lombok.Data;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Arrays;
import java.util.List;

import java.io.Serializable;

@Entity
@Data
@Table(name = "Customers")
public class Customer2 implements Serializable {
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Id
	private  int id;

	@Column(name = "firstname")
	private  String firstName;

	@Column(name = "lastname")
	private String lastName;
}

```
定義 Repository
```
package com.example.demo;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface CustomerRepository extends JpaRepository<Customer2,Integer> ,
	   JpaSpecificationExecutor<Customer2> {
		   Customer2 findById(int id);
	   }

```
Controller 應該還可以補個 Service
```
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("customer")
public class CustomerController {

	@Autowired
	private CustomerRepository customerRepository;


	@GetMapping("all")
	public List<Customer2> getCustomers(){
		List<Customer2> all = customerRepository.findAll();
		return all;
	}
}

```
看書上可以支援一對一關係就順便玩看看 , 關鍵是要設定 `OneToOne` 還有 `JoinColumn` 這兩個
```
package com.example.demo;

import lombok.Data;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Arrays;
import java.util.List;

import java.io.Serializable;

@Entity
@Data
@Table(name = "Customers")
public class Customer2 implements Serializable {
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Id
	private  int id;

	@Column(name = "firstname")
	private  String firstName;

	@Column(name = "lastname")
	private String lastName;

	@OneToOne(cascade = CascadeType.ALL)
	@JoinColumn(name = "id")
	private  Card card;
}


@Entity
@Table(name ="card")
@Data
public class Card {
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private int id;
	private Integer num;
}

```
