---
title: fastapi 筆記
date: 2025-04-26 02:48:57
tags: python
---
&nbsp;
<!-- more -->

### helloworld
建立環境
```
python -m venv fastapienv
```

啟動
```
.\fastapienv\Scripts\Activate.ps1
```

退出
```
deactivate
```

pip 安裝
```
pip install fastapi
pip install "uvicorn[standard]"
pip list
```

conda 安裝
```
conda install fastapi
conda install uvicorn-standard
```

啟動 uvicorn web server
```
uvicorn books:app --reload
```

另一種啟動方法
```
fastapi run books.py
```

預設會在 http://127.0.0.1:8000/ 這個路徑進去的話會給這樣
```
{"detail":"Not Found"}
```

想要進去 swagger 路徑要這樣寫 http://127.0.0.1:8000/docs
另外還有一套 redoc http://127.0.0.1:8000/redoc

\ 表示換行


path parameter = .net 的 route parameter
query parameter = query parameter

post 要先 import 才可以使用
```
from fastapi import FastAPI, Path, Query, HTTPException, Body
```

Body() = FromBody

@app.post("qq")
async def QQ(xxx=Body()) = FromBody

post json 必須要使用雙引號


### uvicorn 不正常關閉
這問題滿鳥的, 直接把 python 砍了就好, 不然找 process 起來也是砍不到
```
netstat -ano | findstr :8000

TCP    127.0.0.1:8000          0.0.0.0:0              LISTENING       5944


🌹 taskkill /PID 5944 /F
錯誤: 找不到處理程序 "5944"。
```

### Pydantic
Pydantic => 驗證資料用的咚咚

可以在 `Field` 加上想要驗證的設定即可
需要引用以下的咚咚
```
from pydantic import BaseModel, Field
```

`model_config` 則是會出現在 swagger 上面的說明

```
class Book:
    id: int
    title: str
    author: str
    description: str
    rating: int
    published_date: int

    def __init__(self, id, title, author, description, rating, published_date):
        self.id = id
        self.title = title
        self.author = author
        self.description = description
        self.rating = rating
        self.published_date = published_date



class BookRequest(BaseModel):
    id: Optional[int] = Field(description='ID is not needed on create', default=None)
    title: str = Field(min_length=3)
    author: str = Field(min_length=1)
    description: str = Field(min_length=1, max_length=100)
    rating: int = Field(gt=0, lt=6)
    published_date: int = Field(gt=1999, lt=2031)

    model_config = {
        "json_schema_extra": {
            "example": {
                "title": "A new book",
                "author": "codingwithroby",
                "description": "A new description of a book",
                "rating": 5,
                'published_date': 2029
            }
        }
    }


@app.post("/create-book", status_code=status.HTTP_201_CREATED)
async def create_book(book_request: BookRequest):
    new_book = Book(**book_request.model_dump())
    BOOKS.append(find_book_id(new_book))


def find_book_id(book: Book):
    book.id = 1 if len(BOOKS) == 0 else BOOKS[-1].id + 1
    return book

```

### sqlalchemy 煉金術

先到 https://www.sqlite.org/download.html 官網下載管理工具 sqlite-tools-win-x64-3490100.zip 然後 rename 為 sqlite3 放到 c 底下
接著用 `win + env` 可以快速叫出環境變數編輯的介面, 這裡要選系統的, 不要選成自己帳號, 將 `C:\sqlite3` 加入 `path`
用以下方是開啟 db
```
sqlite3 todos.db
```

`.schema` 命令則可以看到目前資料表結構
`.mode column` 則可以變換輸出模式, 他還支援 `markdown` 等一狗票輸出滿酷
```
sqlite> .schema
CREATE TABLE todos (
        id INTEGER NOT NULL,
        title VARCHAR,
        description VARCHAR,
        priority INTEGER,
        complete BOOLEAN,
        PRIMARY KEY (id)
);
CREATE INDEX ix_todos_id ON todos (id);
```

接著隨便新增 5 筆資料

```
INSERT INTO todos (id, title, description, priority, complete) VALUES (1, 'Buy groceries', 'Milk, Bread, Eggs', 2, 0);
INSERT INTO todos (id, title, description, priority, complete) VALUES (2, 'Workout', 'Gym session at 6 PM', 3, 0);
INSERT INTO todos (id, title, description, priority, complete) VALUES (3, 'Read book', 'Finish reading Chapter 4', 1, 1);
INSERT INTO todos (id, title, description, priority, complete) VALUES (4, 'Call Alice', 'Discuss weekend plans', 2, 0);
INSERT INTO todos (id, title, description, priority, complete) VALUES (5, 'Pay bills', 'Electricity and Internet', 3, 1);

| id |     title     |       description        | priority | complete |
|----|---------------|--------------------------|----------|----------|
| 1  | Buy groceries | Milk, Bread, Eggs        | 2        | 0        |
| 2  | Workout       | Gym session at 6 PM      | 3        | 0        |
| 3  | Read book     | Finish reading Chapter 4 | 1        | 1        |
| 4  | Call Alice    | Discuss weekend plans    | 2        | 0        |
| 5  | Pay bills     | Electricity and Internet | 3        | 1        |
```


安裝
```
conda install sqlalchemy
```

新增 TodoApp 資料夾, 加入以下檔案

`database.py`
```
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

SQLALCHEMY_DATABASE_URL = 'sqlite:///./todosapp.db'

engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={'check_same_thread': False})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


```

`models.py`
這邊定義欄位型別, 水應該也很深
```
from database import Base
from sqlalchemy import Column, Integer , String , Boolean


class Todos(Base):
    __tablename__ = 'todos'

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    priority = Column(Integer)
    complete = Column(Boolean, default=False)
```

`main.py`
這裡執行這句 `models.Base.metadata.create_all(bind=engine)` 以後, 然後啟動 `uvicorn main:app --reload` 就會出現 `todo.db`
依照以前用 ef 的經驗這種咚咚就是難用 LOL
```
from typing import Annotated
from sqlalchemy.orm import Session
from fastapi import FastAPI , Depends

import models
from models import Todos
from database import engine, SessionLocal

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
async def read_all(db:Annotated[Session, Depends(get_db)]):
    return db.query(Todos).all()


```

接著可以建立以 id 查詢的函數
```
@app.get("/todo/{todo_id}", status_code=status.HTTP_200_OK)
async def read_todo(db: db_dependency, todo_id: int = Path(gt=0)):
    todo_model = db.query(Todos).filter(Todos.id == todo_id).first()
    if todo_model is not None:
        return todo_model
    raise HTTPException(status_code=404, detail='Todo not found')

```

post
```
class TodoRequest(BaseModel):
    title: str = Field(min_length=3)
    description: str = Field(min_length=3, max_length=100)
    priority: int = Field(gt=0, lt=6)
    complete: bool


@app.post("/todo", status_code=status.HTTP_201_CREATED)
async def create_todo(db: db_dependency, todo_request: TodoRequest):
    todo_model = Todos(**todo_request.dict())
    db.add(todo_model)
    db.commit()

```

put
```
@app.put("/todo",status_code=status.HTTP_204_NO_CONTENT)
async def update_todo(db:db_dependency, todo_id:int, todo_request:TodoRequest):
    todo_model = db.query(Todos).filter(Todos.id == todo_id).first()

    if todo_model is None:
        raise HTTPException(status_code=404, detail='Todo not found')

    todo_model.title = todo_request.title
    todo_model.description = todo_request.description
    todo_model.priority = todo_request.priority
    todo_model.complete = todo_request.complete

    db.add(todo_model)
    db.commit()

```


delete
```
@app.delete("/todo", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(db: db_dependency, todo_id: int = Path(gt=0)):
    todo_model = db.query(Todos).filter(Todos.id == todo_id).first()
    if todo_model is None:
        raise HTTPException(status_code=404, detail='Todo not found')
    db.query(Todos).filter(Todos.id == todo_id).delete()
    db.commit()

```

### Authentication & Authorization

先建立 `package routers` 接著新增 `auth.py` 在該目錄底下

```
from fastapi import FastAPI , APIRouter

router = APIRouter()

@router.get("/auth/")
async def auth():
    return {"user": "authenticated"}

```

回到 `main.py` 修改並且引用剛剛建立的 `routers`
```
from routers import auth

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

app.include_router(auth.router)


```

最後啟動即可

```
uvicorn main:app --reload
```

接著來重構內容, 加入 `todos.py` 把 `main.py` 內容複製並修改如下
主要異動就是把 `app` 改成 `APIRouter`

```
from typing import Annotated, cast

from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, status, Path

from models import Todos
from database import  SessionLocal

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]


class TodoRequest(BaseModel):
    title: str = Field(min_length=3)
    description: str = Field(min_length=3, max_length=100)
    priority: int = Field(gt=0, lt=6)
    complete: bool


@router.get("/")
async def read_all(db: db_dependency):
    return db.query(Todos).all()


@router.get("/todo/{todo_id}", status_code=status.HTTP_200_OK)
async def read_todo(db: db_dependency, todo_id: int = Path(gt=0)):
    todo_model = db.query(Todos).filter(cast("ColumnElement[bool]", Todos.id == todo_id)).first()
    if todo_model is not None:
        return todo_model
    raise HTTPException(status_code=404, detail='Todo not found')


@router.post("/todo", status_code=status.HTTP_201_CREATED)
async def create_todo(db: db_dependency, todo_request: TodoRequest):
    todo_model = Todos(**todo_request.dict())
    db.add(todo_model)
    db.commit()


@router.put("/todo", status_code=status.HTTP_204_NO_CONTENT)
async def update_todo(db: db_dependency, todo_id: int, todo_request: TodoRequest):
    todo_model = db.query(Todos).filter(cast("ColumnElement[bool]", Todos.id == todo_id)).first()

    if todo_model is None:
        raise HTTPException(status_code=404, detail='Todo not found')

    todo_model.title = todo_request.title
    todo_model.description = todo_request.description
    todo_model.priority = todo_request.priority
    todo_model.complete = todo_request.complete

    db.add(todo_model)
    db.commit()


@router.delete("/todo/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(db: db_dependency, todo_id: int = Path(gt=0)):
    todo_model = db.query(Todos).filter(Todos.id == todo_id).first()
    if todo_model is None:
        raise HTTPException(status_code=404, detail='Todo not found')
    db.query(Todos).filter(Todos.id == todo_id).delete()
    db.commit()

```

並且修正 `main.py` 加入剛剛的 `todos` `router` 並且移除不需要的部分即可完成

```
from fastapi import FastAPI

import models
from database import engine
from routers import auth , todos

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(todos.router)

```

接續修改 `database.py` 把本來的 `todos.db` 改為 `todosapp.db`
這裡要注意下, 萬一 `uvicorn main:app --reload` 還在運作的話會馬上生效

```
SQLALCHEMY_DATABASE_URL = 'sqlite:///./todosapp.db'

```

接著在 `models.py` 底下調整程式碼, 主要加入了 `Users` 這張表, 並且調整 `Todos` 關聯
```
from database import Base
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey


class Users(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True)
    username = Column(String, unique=True)
    first_name = Column(String)
    last_name = Column(String)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)
    role = Column(String)


class Todos(Base):
    __tablename__ = 'todos'

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(String)
    priority = Column(Integer)
    complete = Column(Boolean, default=False)
    owner_id = Column(Integer, ForeignKey("user.id"))


```

回到 `auth.py` 修改程式碼, 搞定後就可以測試看看是否正常 `post`
```
from Demos.win32ts_logoff_disconnected import username
from fastapi import FastAPI, APIRouter
from pydantic import BaseModel
from models import Users

router = APIRouter()


class CreateUserRequest(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str
    role: str


@router.post("/auth")
async def create_user(create_user_request: CreateUserRequest):
    create_user_model = Users(
        email=create_user_request.email,
        username=create_user_request.username,
        first_name=create_user_request.first_name,
        last_name=create_user_request.last_name,
        role=create_user_request.role,
        hashed_password=create_user_request.password,
        is_active=True
    )
    return create_user_model

```

接著安裝套件 `passlib`

```
conda install passlib
#這個在 conda 找不到所以用 pip 安裝
pip install bcrypt==4.0.1
```

修改 `auth.py` 把密碼欄位加密, 並且確實的寫入到 db 內
```
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status, Path
from pydantic import BaseModel

from sqlalchemy.orm import Session

from database import SessionLocal
from models import Users
from passlib.context import CryptContext

router = APIRouter()

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]


class CreateUserRequest(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str
    role: str


@router.post("/auth", status_code=status.HTTP_201_CREATED)
async def create_user(
        db: db_dependency,
        create_user_request: CreateUserRequest):
    create_user_model = Users(
        email=create_user_request.email,
        username=create_user_request.username,
        first_name=create_user_request.first_name,
        last_name=create_user_request.last_name,
        role=create_user_request.role,
        hashed_password=bcrypt_context.hash(create_user_request.password),
        is_active=True
    )
    db.add(create_user_model)
    db.commit()


```

post 以下參數
```
{
  "username": "qq",
  "email": "qq@gmail.com",
  "first_name": "qq",
  "last_name": "qq",
  "password": "qq",
  "role": "admin"
}
```

然後用 sqlite 看看結果
```
sqlite> select * from users;
| id |    email     | username | first_name | last_name |                       hashed_password                        | is_active | role  |
|----|--------------|----------|------------|-----------|--------------------------------------------------------------|-----------|-------|
| 1  | qq@gmail.com | qq       | qq         | qq        | $2b$12$/NLBaJB01yCy3sxOg2JwpOGJkZS5gXNgxy1j6sZ190c580Ot0u.j6 | 1         | admin |
```

接著安裝以下套件
```
conda install python-multipart
```

引用此命名空間 `from fastapi.security import OAuth2PasswordRequestForm` 並且調整程式碼

他會出現讓人熟悉的 OAuth 欄位 XD 但只有 username password 必填

grant_type
username 
password 
scope
client_id
client_secret

```
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status, Path
from pydantic import BaseModel

from sqlalchemy.orm import Session

from database import SessionLocal
from models import Users
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter()

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]


class CreateUserRequest(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str
    role: str


@router.post("/auth", status_code=status.HTTP_201_CREATED)
async def create_user(
        db: db_dependency,
        create_user_request: CreateUserRequest):
    create_user_model = Users(
        email=create_user_request.email,
        username=create_user_request.username,
        first_name=create_user_request.first_name,
        last_name=create_user_request.last_name,
        role=create_user_request.role,
        hashed_password=bcrypt_context.hash(create_user_request.password),
        is_active=True
    )
    db.add(create_user_model)
    db.commit()


def authenticate_user(username: str, password: str, db):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not bcrypt_context.verify(password, user.hashed_password):
        return False
    return True


@router.post("/token")
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
        db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)
    if not user:
        return 'Failed Authentication'
    return 'Successful Authentication'

```

接著加入 JWT 功能, 先安裝套件
```
pip install python-jose[cryptography]
```

加入以下程式碼
```
SECRET_KEY = '0123456789'
ALGORITHM = 'HS256'
def create_access_token(username: str, user_id: int, expires_delta: timedelta):
    encode = {'sub': username, 'id': user_id}
    expires = datetime.now(timezone.utc) + expires_delta
    encode.update({'exp': expires})
    return jwt.encode(encode, SECRET_KEY, ALGORITHM)

```

然後調整 `login_for_access_token` 相關程式碼, 這裡的 `authenticate_user` 改為 return user
他這邊如果打錯 username or password 會噴 internal server error 是正常的, 因為他把 `response_model=Token` 設定這樣, 導致本來隨便回傳有了強制限定
```
class Token(BaseModel):
    access_token: str
    token_type: str

def authenticate_user(username: str, password: str, db):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not bcrypt_context.verify(password, user.hashed_password):
        return False
    return user


@router.post("/token", response_model=Token)
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
        db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)
    if not user:
        return 'Failed Authentication'
    token = create_access_token(user.username, user.id, timedelta(minutes=20))
    return {'access_token': token, 'token_type': 'bearer'}

```

fullcode
```
from datetime import timedelta, datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status, Path
from pydantic import BaseModel

from sqlalchemy.orm import Session

from database import SessionLocal
from models import Users
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm
from jose import jwt

router = APIRouter()

SECRET_KEY = '0123456789'
ALGORITHM = 'HS256'

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]


class CreateUserRequest(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str
    role: str


class Token(BaseModel):
    access_token: str
    token_type: str


def create_access_token(username: str, user_id: int, expires_delta: timedelta):
    encode = {'sub': username, 'id': user_id}
    expires = datetime.now(timezone.utc) + expires_delta
    encode.update({'exp': expires})
    return jwt.encode(encode, SECRET_KEY, ALGORITHM)


@router.post("/auth", status_code=status.HTTP_201_CREATED)
async def create_user(
        db: db_dependency,
        create_user_request: CreateUserRequest):
    create_user_model = Users(
        email=create_user_request.email,
        username=create_user_request.username,
        first_name=create_user_request.first_name,
        last_name=create_user_request.last_name,
        role=create_user_request.role,
        hashed_password=bcrypt_context.hash(create_user_request.password),
        is_active=True
    )
    db.add(create_user_model)
    db.commit()


def authenticate_user(username: str, password: str, db):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not bcrypt_context.verify(password, user.hashed_password):
        return False
    return user


@router.post("/token", response_model=Token)
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
        db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')

    token = create_access_token(user.username, user.id, timedelta(minutes=20))
    return {'access_token': token, 'token_type': 'bearer'}

```

最後加入以下 decode 程式碼

```
async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        return {'username': username, 'id': user_id, 'user_role': user_role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')


```

重構 router 路徑
```
from datetime import timedelta, datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status, Path
from pydantic import BaseModel
from pygments.lexer import default

from sqlalchemy.orm import Session

from database import SessionLocal
from models import Users
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from jose import jwt, JWTError

router = APIRouter(
    prefix="/auth",
    tags=['auth']
)

SECRET_KEY = '0123456789'
ALGORITHM = 'HS256'

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')
oauth2_bearer = OAuth2PasswordBearer(tokenUrl='auth/token')


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]


class CreateUserRequest(BaseModel):
    username: str
    email: str
    first_name: str
    last_name: str
    password: str
    role: str


class Token(BaseModel):
    access_token: str
    token_type: str


def create_access_token(username: str, user_id: int, expires_delta: timedelta):
    encode = {'sub': username, 'id': user_id}
    expires = datetime.now(timezone.utc) + expires_delta
    encode.update({'exp': expires})
    return jwt.encode(encode, SECRET_KEY, ALGORITHM)


async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        return {'username': username, 'id': user_id, 'user_role': user_role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')



@router.post("/", status_code=status.HTTP_201_CREATED)
async def create_user(
        db: db_dependency,
        create_user_request: CreateUserRequest):
    create_user_model = Users(
        email=create_user_request.email,
        username=create_user_request.username,
        first_name=create_user_request.first_name,
        last_name=create_user_request.last_name,
        role=create_user_request.role,
        hashed_password=bcrypt_context.hash(create_user_request.password),
        is_active=True
    )
    db.add(create_user_model)
    db.commit()


def authenticate_user(username: str, password: str, db):
    user = db.query(Users).filter(Users.username == username).first()
    if not user:
        return False
    if not bcrypt_context.verify(password, user.hashed_password):
        return False
    return user


@router.post("/token", response_model=Token)
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
        db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)
    print("user:", user)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')
    token = create_access_token(user.username, user.id, timedelta(minutes=20))
    print(token)
    return {'access_token': token, 'token_type': 'bearer'}

```

接著調整 `todos.py` 匯入 get_current_user 方法, 注意這邊要用 `.auth` 表示目前目錄底下

```
from .auth import get_current_user
```

接著補上注入, 並調整 `create_todo` 開 swagger 測試登入後能否新增
```
user_dependency = Annotated[dict, Depends(get_current_user)]

@router.post("/todo", status_code=status.HTTP_201_CREATED)
async def create_todo(
        user: user_dependency,
        db: db_dependency,
        todo_request: TodoRequest):
    if user is None:
        raise HTTPException(status_code=401, detail="Authentication Failed")
    todo_model = Todos(**todo_request.dict(), owner_id=user.get('id'))
    db.add(todo_model)
    db.commit()

```

接著調整 `read_all` 讓只有該 user 能看到自己的資料
```
@router.get("/")
async def read_all(
        user: user_dependency,
        db: db_dependency):
    if user is None:
        raise HTTPException(status_code=401, detail="Authentication Failed")
    return db.query(Todos).filter(Todos.owner_id == user.get('id')).all()

```

修改 `read_todo` 一樣限定只有自己才能看見, 這裡看是要用 \ 換行, 或是用小括號包住都可以
```
@router.get("/todo/{todo_id}", status_code=status.HTTP_200_OK)
async def read_todo(
        user: user_dependency,
        db: db_dependency,
        todo_id: int = Path(gt=0)):
    if user is None:
        raise HTTPException(status_code=401, detail="Authentication Failed")

    todo_model = (db.query(Todos)
                  .filter(cast("ColumnElement[bool]", Todos.id == todo_id))
                  .filter(Todos.owner_id == user.get('id'))
                  .first())
    if todo_model is not None:
        return todo_model
    raise HTTPException(status_code=404, detail='Todo not found')

```

修改 put 跟 delete 方法

```
@router.put("/todo", status_code=status.HTTP_204_NO_CONTENT)
async def update_todo(
        user: user_dependency,
        db: db_dependency,
        todo_id: int, todo_request: TodoRequest):
    if user is None:
        raise HTTPException(status_code=401, detail="Authentication Failed")

    todo_model = (db.query(Todos).filter(Todos.id == todo_id)
                  .filter(Todos.owner_id == user.get('id'))
                  .first())

    if todo_model is None:
        raise HTTPException(status_code=404, detail='Todo not found')

    todo_model.title = todo_request.title
    todo_model.description = todo_request.description
    todo_model.priority = todo_request.priority
    todo_model.complete = todo_request.complete

    db.add(todo_model)
    db.commit()


@router.delete("/todo/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(
        user: user_dependency,
        db: db_dependency,
        todo_id: int = Path(gt=0)):
    if user is None:
        raise HTTPException(status_code=401, detail="Authentication Failed")

    todo_model = (db.query(Todos).filter(Todos.id == todo_id)
                  .filter(Todos.owner_id == user.get('id'))
                  .first())
    if todo_model is None:
        raise HTTPException(status_code=404, detail='Todo not found')
    db.query(Todos).filter(Todos.id == todo_id).delete()
    db.commit()

```

接著建立管理員相關功能, 先調整 `create_access_token` `get_current_user` `login_for_access_token` 加入角色
```
def create_access_token(username: str, user_id: int, role: str, expires_delta: timedelta):
    encode = {'sub': username, 'id': user_id, 'role': role}
    expires = datetime.now(timezone.utc) + expires_delta
    encode.update({'exp': expires})
    return jwt.encode(encode, SECRET_KEY, ALGORITHM)


async def get_current_user(token: Annotated[str, Depends(oauth2_bearer)]):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get('sub')
        user_id: int = payload.get('id')
        user_role: str = payload.get('role')
        if username is None or user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                detail='Could not validate user.')
        return {'username': username, 'id': user_id, 'user_role': user_role}
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')

@router.post("/token", response_model=Token)
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
        db: db_dependency):
    user = authenticate_user(form_data.username, form_data.password, db)
    print("user:", user)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail='Could not validate user.')
    token = create_access_token(user.username, user.id, user.role, timedelta(minutes=20))
    print(token)
    return {'access_token': token, 'token_type': 'bearer'}

```

在 `routers` 資料夾底下加入 `admin.py` 並加入相關權限的 api
```
from typing import Annotated, cast

from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, status, Path

from models import Todos
from database import SessionLocal
from .auth import get_current_user

router = APIRouter(
    prefix="/admin",
    tags=['admin']
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]


@router.get("todo", status_code=status.HTTP_200_OK)
async def read_all(user: user_dependency, db: db_dependency):
    if user is None or user.get('user_role') != 'admin':
        raise HTTPException(status_code=401, detail='Authentication Failed')
    return db.query(Todos).all()


@router.delete("/todo/{todo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_todo(user: user_dependency, db: db_dependency, todo_id: int = Path(gt=0)):
    if user is None or user.get('user_role') != 'admin':
        raise HTTPException(status_code=401, detail='Authentication Failed')
    todo_model = db.query(Todos).filter(Todos.id == todo_id).first()
    if todo_model is None:
        raise HTTPException(status_code=401, detail='Todo not found.')
    db.query(Todos).filter(Todos.id == todo_id).delete()
    db.commit()

```

別忘了要在 `main.py` 底下加入 `app.include_router(admin.router)`

```
from fastapi import FastAPI

import models
from database import engine
from routers import auth , todos, admin
#from routers import auth , todos, admin , users

app = FastAPI()

models.Base.metadata.create_all(bind=engine)

app.include_router(auth.router)
app.include_router(todos.router)
app.include_router(admin.router)
# app.include_router(users.router)

```

最後建立可以修改密碼的 `users.py`

```
from typing import Annotated, cast

from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends, HTTPException, status, Path

from models import Todos, Users
from database import SessionLocal
from .auth import get_current_user
from passlib.context import CryptContext

router = APIRouter(
    prefix="/user",
    tags=['user']
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


db_dependency = Annotated[Session, Depends(get_db)]
user_dependency = Annotated[dict, Depends(get_current_user)]
bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated='auto')


class UserVerification(BaseModel):
    password: str
    new_password: str = Field(min_length=6)


@router.get("/", status_code=status.HTTP_200_OK)
async def get_user(user: user_dependency, db: db_dependency):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')
    return db.query(Users).filter(Users.id == user.get('id')).first()


@router.put("/password", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(user: user_dependency, db: db_dependency, user_verification: UserVerification):
    if user is None:
        raise HTTPException(status_code=401, detail='Authentication Failed')
    user_model = db.query(Users).filter(Users.id == user.get('id')).first()
    if not bcrypt_context.verify(user_verification.password, user_model.hashed_password):
        raise HTTPException(status_code=401, detail='Error on password change')
    user_model.hashed_password = bcrypt_context.hash(user_verification.new_password)
    db.add(user_model)
    db.commit()

```



### 畫一隻土撥鼠

```
import io
from typing import Optional
from fastapi import FastAPI, Path, Query, HTTPException, Body
from pydantic import BaseModel, Field
from starlette import status
import numpy as np
import cv2
import matplotlib.pyplot as plt
from fastapi.responses import StreamingResponse

app = FastAPI()


@app.get("/marmot")
async def marmot():
    # 讀圖 + 轉成 RGB
    marmot = cv2.imread('marmot.jpg')
    marmot = cv2.cvtColor(marmot, cv2.COLOR_BGR2RGB)

    # 畫圖但不顯示
    fig, ax = plt.subplots()
    ax.imshow(marmot)
    ax.axis('off')  # 不顯示座標軸

    # 儲存到記憶體
    buf = io.BytesIO()
    plt.savefig(buf, format='png', bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)

    # 回傳成 image/png
    return StreamingResponse(buf, media_type="image/png")

```


### pycharm debug

點選上方工具列的 Run → Edit Configurations...

點左上角的 ➕ 新增一個配置

選擇：Python

設定以下欄位：


欄位	設定內容
Name	FastAPI（你可以自訂）
Script path	✅ 勾選 "Module name"
Module name	uvicorn
Parameters	main:app --reload（視你的檔案名而定）
Python interpreter	選你要的虛擬環境
Working directory	專案根目錄即可

設定好後點 debug 然後打中斷點 f5 下去就搞定