readOnlinePic
=============

读取远程图片或者文件并存储到本地

# summary

* 读取远程文件到指定路径并提供回调
* @param picUrl string 要读取的图片的路径
* @param targetPath string 目标存储路径，写完整，类型自行判断，无法根据content-type判断，可伪装
* @param callback function 回调方法，写入完成或者出错的时候回调 callback(info,error) 
* 回调数据 出错时为空对象{}，成功时为 {
                        targetPath:targetPath,
                        picUrl:picUrl
                    }
* @author yutou 
* @email xinyu198736@gmail.com
* @blog http://www.html-js.com

***

#install
<pre>npm install readof</pre>

***

#clone
<pre>$ git clone https://bitbucket.org/xinyu198736/readonlinefile.git/wiki</pre>

***

#code
<pre>
    var readOF=require("readof");
         readOF.read(pic,target_path,function(error,data){
            //do something
    });
    </pre>