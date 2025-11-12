#!/bin/bash  
#set -x

package=$1 
NOW=$(date +"%Y-%m-%d-%H-%M")
PWD=`pwd`
VERSION=`grep "var version" main.go | awk -F'"' '{print $2}'`

if [[ -z "$package" ]]; then   
	echo "usage: $0 <package-name>"   
	exit 1 
fi 
package_split=(${package//\// }) 
package_name="lazydocker" 

# cleanup

mv ${PWD}/build/${package_name}* ${PWD}/build/backup/

platforms=("windows/amd64" "windows/arm64" "windows/arm/v6" "windows/arm/v7" "linux/386" "linux/amd64" "linux/arm64" "linux/arm/v6" "linux/arm/v7" "darwin/amd64" "darwin/arm64")  
for platform in "${platforms[@]}" 
do     
	platform_split=(${platform//\// })     
	GOOS=${platform_split[0]}     
	GOARCH=${platform_split[1]}     
	GOARM=""
	if [ "${platform_split[2]}" != "" ]; then
		GOARM=${platform_split[2]//v/}
		output_name=./build/$package_name'_'$VERSION'_'$GOOS'_'$GOARCH'v'$GOARM
	else
		output_name=./build/$package_name'_'$VERSION'_'$GOOS'_'$GOARCH
	fi
	if [ $GOOS = "windows" ]; then         
		output_name+='.exe'     
	fi      
	if [ -n "$GOARM" ]; then
		env GOOS=$GOOS GOARCH=$GOARCH GOARM=$GOARM go build -o $output_name $package
	else
		env GOOS=$GOOS GOARCH=$GOARCH go build -o $output_name $package
	fi     
	if [ $? -ne 0 ]; then         
		echo 'An error has occurred! Aborting the script execution...'         
		exit 1     
	else
		if [ $GOOS = "darwin" ]; then
			new_name=${output_name//darwin/Darwin}
			if [ $GOARCH = "amd64" ]; then
				new_name=${new_name//amd64/x86_64}
			fi
			mv $output_name $new_name
			archive_dir=$(dirname $new_name)/$(basename $new_name | sed 's/\.exe$//')
			temp_binary=$(dirname $new_name)/.tmp_$(basename $new_name)
			mv $new_name $temp_binary
			rm -rf $archive_dir
			mkdir -p $archive_dir
			mv $temp_binary $archive_dir/$package_name
			cp LICENSE $archive_dir/
			cp README.md $archive_dir/
			tar czvf $archive_dir.tar.gz -C $(dirname $archive_dir) $(basename $archive_dir)
			rm -rf $archive_dir
		elif [ $GOOS = "linux" ]; then
			new_name=${output_name//linux/Linux}
			if [ $GOARCH = "amd64" ]; then
				new_name=${new_name//amd64/x86_64}
			elif [ $GOARCH = "386" ]; then
				new_name=${new_name//386/x86}
			fi
			mv $output_name $new_name
			archive_dir=$(dirname $new_name)/$(basename $new_name | sed 's/\.exe$//')
			temp_binary=$(dirname $new_name)/.tmp_$(basename $new_name)
			mv $new_name $temp_binary
			rm -rf $archive_dir
			mkdir -p $archive_dir
			mv $temp_binary $archive_dir/$package_name
			cp LICENSE $archive_dir/
			cp README.md $archive_dir/
			tar czvf $archive_dir.tar.gz -C $(dirname $archive_dir) $(basename $archive_dir)
			rm -rf $archive_dir
		elif [ $GOOS = "windows" ]; then
			new_name=${output_name//windows/Windows}
			if [ $GOARCH = "amd64" ]; then
				new_name=${new_name//amd64/x86_64}
			fi
			mv $output_name $new_name
			archive_dir=$(dirname $new_name)/$(basename $new_name | sed 's/\.exe$//')
			rm -rf $archive_dir
			mkdir -p $archive_dir
			mv $new_name $archive_dir/$package_name.exe
			cp LICENSE $archive_dir/
			cp README.md $archive_dir/
			(cd $(dirname $archive_dir) && zip -r $(basename $archive_dir).zip $(basename $archive_dir))
			rm -rf $archive_dir
		fi 
	fi
done

