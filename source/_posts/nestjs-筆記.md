---
title: nestjs 筆記
date: 2023-11-20 18:29:18
tags:
- nestjs
- js
---
&nbsp;
<!-- more -->

### 產生 class
照著課程練習發現建出來的檔案會有問題
猜可能新版都要用 `--flat` 建立
用 `-d` 可以試跑看看
```
nest g class coffees/dto/create-coffee.dto --no-spec --flat -d
```

### typeorm migration
看課程上面的指令都是舊版的 , 陣亡得不要不要的 XD

migration 發現新版的要改成建立 ormconfig.ts
```
import { DataSource } from "typeorm";

export const connectionSource = new DataSource({
    migrationsTableName: 'migrations',
    type: 'postgres',
    host: 'localhost',
    port: 5432,
    username: 'postgres',
    password: 'postgres',
    database: 'postgres',
    logging: true,
    synchronize: false,
    name: 'default',
    entities: ['src/**/**.entity{.ts,.js}'],
    migrations: ['src/migrations/**/*{.ts,.js}'],
    subscribers: ['src/subscriber/**/*{.ts,.js}'],
});
```

這個表示 `migrationsTableName` 的資料表

然後命令要這樣打
```
npx typeorm-ts-node-commonjs migration:run -d ormconfig.ts
```

倒回去也要加上 -d
```
npx typeorm-ts-node-commonjs migration:revert -d ormconfig.ts
```

要用 generate 之前需要先修改欄位 , 不過好像沒修改也是會過

generate 要先打想要的路徑 `src\migrations` , 然後接上更新的內容 , 這裡用 `SchemaSync`
最後別忘了加上 -d
```
npx typeorm-ts-node-commonjs migration:generate src\migrations\SchemaSync -d ormconfig.ts
```

然後他就會在你的資料夾底下多一個這樣的檔案 `1700462866328-SchemaSync.ts`
``` ts
import { MigrationInterface, QueryRunner } from "typeorm";

export class SchemaSync1700462866328 implements MigrationInterface {
    name = 'SchemaSync1700462866328'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`CREATE TABLE "event" ("id" SERIAL NOT NULL, "type" character varying NOT NULL, "name" character varying NOT NULL, "payload" json NOT NULL, CONSTRAINT "PK_30c2f3bbaf6d34a55f8ae6e4614" PRIMARY KEY ("id"))`);
        await queryRunner.query(`CREATE INDEX "IDX_b535fbe8ec6d832dde22065ebd" ON "event" ("name") `);
        await queryRunner.query(`CREATE INDEX "IDX_6e1de41532ad6af403d3ceb4f2" ON "event" ("name", "type") `);
        await queryRunner.query(`ALTER TABLE "coffee" ADD "description" character varying`);
        await queryRunner.query(`ALTER TABLE "coffee" ADD "recommendations" integer NOT NULL DEFAULT '0'`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "coffee" DROP COLUMN "recommendations"`);
        await queryRunner.query(`ALTER TABLE "coffee" DROP COLUMN "description"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_6e1de41532ad6af403d3ceb4f2"`);
        await queryRunner.query(`DROP INDEX "public"."IDX_b535fbe8ec6d832dde22065ebd"`);
        await queryRunner.query(`DROP TABLE "event"`);
    }

}
```

最後產生完記得要再次跑 , 結論不管哪個語言的 migration 都一樣難用 XD
```
npx typeorm-ts-node-commonjs migration:run -d ormconfig.ts
```
