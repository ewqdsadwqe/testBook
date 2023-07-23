#!/bin/bash 

rm -rf $2
cp -r $1 $2

if [ ! -e $2 ]; then
	mkdir -p $2
fi

# /usr/lib/jvm/java-11-openjdk-amd64/bin/java -Xms700M -cp /home/demo/Desktop/tool/idea-IU-213.6777.52/plugins/java-decompiler/lib/java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true $1 $2

find $1 -name "*.war" -type f | xargs -I xx unzip xx -d xx.folder
find $2 -name "*.jar.sig" -type f | xargs rm

if [ ! -e storeLib ]; then
	mkdir storeLib
fi
find $1 -name "*.jar" -type f | xargs -I jarPath  cp jarPath storeLib/
# find $2 -name "*.jar" -type f | xargs -I jarPath  mv jarPath jarPath.sou.jar
mv storeLib $2/

# # decompiler class

skipList=( \
	# "spring"\
	"log4j"\
	"asm"\
	"hibernate"\
	"commons-collection"\
	"fastjson"\
	"slf4j"\
	"javax"\
	"jersey"\
	"jackson"\
	"netty"\
	"osgi"\
	"eclipse"\
	"jboss"\
	"jakarta"\
	"aspect"\
	"swagger"\
	# "jwt-token"\
	"javassist"\
	"asm-commons"\
	"freemarker"\
	"sqljdbc"\
	"logging"\
	"aws"\
	"xray"\
	"vertx"\
	"taglibs"\
	# "opensaml"\
	"jna-3.2.7"\
	"dom4j"\
	"postgresql"\
	"elasticsearch"\
	"azure"\
	"google"\
	"gson"\
	"grpc"\
	"jetty"\
	"messagebus"\
	# "joda"\
	# "wavefront"\
	"metrics"\
	"kotin"\
	"apache"\
	"antlr"\
	"quota"\
)
# # # decompiler jar
for jarPath in `find $1 -type f -name "*.jar"` 
do
	jarFullBasePath=${jarPath%/*.jar}
	jarBasePath=${jarFullBasePath#*\/}
	jarName=${jarPath##*\/}
	# spring,log4j,hibernate,commons-collection,fastjson,slf4j,javax,jersey,jackson,netty,osgi,eclipse,jboss,
	# jakarta,aspect,swagger,jwt-token,javassist,asm-commons,freemarker,sqljdbc,logging,aws,xray,vertx,taglibs,
	# opensaml,jna-3.2.7,dom4j,postgresql,google-api
	skip="false"
	for skipJarSubStr in ${skipList[@]}
	do
		if [[ "$jarName" == *"$skipJarSubStr"* ]] ; then
			echo "skip ${jarName} for ${skipJarSubStr}"
			skip="true"
				# if [[ "$jarName" == *"tab"*  ]] ; then
				# 	skip="false"
				# fi
			break
		fi
	done
	# skip="true"
	# if [[ "$jarName" == *"tab-"*  ]] ; then
		# skip="false"
	# fi	
	if [[ "$skip" == "true" ]] ; then
		continue
	fi
	
	jarFolderName=${jarName%%\.jar}
	resBasePath="$2/${jarBasePath}"
	resFullPath="$2/${jarBasePath}/${jarName}"
	resFullFolderPath="$2/${jarBasePath}/${jarFolderName}"
	echo "decompile jar : $jarPath -> $resFullFolderPath -> $resFullPath " 
	if [ ! -e $resBasePath ]; then
		mkdir -p $resBasePath
	fi
	timeout 300s /usr/lib/jvm/java-11-openjdk-amd64/bin/java -Xms800M  -cp /home/demo/Desktop/idea-IU-202.6397.94/plugins/java-decompiler/lib/java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true $jarPath $resBasePath
	if [[ $? != 0 ]] ; then
		echo "decomiple jar timeout : ${resFullPath}"
		rm -f $resFullPath
		unzip $jarPath -D $resFullPath
		deResFullFolderPath="${$resFullFolderPath}.folder"
		timeout 300s /usr/lib/jvm/java-11-openjdk-amd64/bin/java -Xms800M  -cp /home/demo/Desktop/idea-IU-202.6397.94/plugins/java-decompiler/lib/java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true $resFullFolderPath $resBasePath $deResFullFolderPath
		continue
	fi
	
	unzip $resFullPath -d $resFullFolderPath
	rm -f $resFullPath
done

for classPath in `find $1 -type f -name "*.class"` 
do
	classFullBasePath=${classPath%/*.class}
		classBasePath=${classFullBasePath#*\/}
	resBasePath="$2/${classBasePath}"
	echo "decompile class : $classPath -> $resBasePath "
	if [ ! -e $resBasePath ]; then
		mkdir -p $resBasePath
	fi
	/usr/lib/jvm/java-11-openjdk-amd64/bin/java -Xms200M -cp /home/demo/Desktop/idea-IU-202.6397.94/plugins/java-decompiler/lib/java-decompiler.jar org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler -dgs=true $classPath $resBasePath
done

