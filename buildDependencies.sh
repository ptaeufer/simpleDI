pool="${PODS_TARGET_SRCROOT}/ResourcePool.swift"
tmpfile=`mktemp`
echo "import Foundation" >> $tmpfile
echo "" >> $tmpfile
echo "@objcMembers" >> $tmpfile
echo "public class ResourcePool : NSObject{" >> $tmpfile
for file in $(find ${basePath} -name "*.swift"); do
for name in $(cat $file | grep "class" | sed -n 's/.*class *\(.*\) *: *DependencyModule.*/\1/p' | sort -u); do

echo "   public static let $(echo "$name" | awk '{print tolower($0)}')_module = $name();" >> $tmpfile

done
done

echo "   public static let dependencies : Dictionary<String,Array<String>> = [" >> $tmpfile
dependenciesFound=0
for file in $(find ${basePath} -name "*.swift"); do
for name in $(cat $file | grep "class" | sed -n 's/.*class *\(.*\) *: *DependencyModule.*/\1/p' | sort -u); do

sed -i '' -e 's/ let / lazy var /g' $file
contents=$(cat $file | grep "lazy var" | sed -n 's/.*lazy var *\([a-zA-Z0-9_\-]*\) *: *\([a-zA-Z0-9_\-]*\) *.*=.*/\1|\2/p')

contents_func=$(cat $file | grep "func" | sed -n 's/.*func *\([a-zA-Z0-9_\-]*\) *.*> *\([a-zA-Z0-9_\-]*\)* *.*/\1|\2/p\')

for _name in $contents_func; do
echo $_name
dependenciesFound=$((dependenciesFound+1))
var1=${_name%|*}
var2=${_name#*|}
echo "\"$(echo "$var2")\" : [\"$(echo "$name")\", \"$(echo "$var1")\", \"instance\"]," >> $tmpfile
done

for _name in $contents; do
dependenciesFound=$((dependenciesFound+1))
var1=${_name%|*}
var2=${_name#*|}
echo "\"$(echo "$var2")\" : [\"$(echo "$name")\", \"$(echo "$var1")\", \"singleton\"]," >> $tmpfile
done
done
done

if [[ "$dependenciesFound" -eq 0 ]]
then
echo "        :" >> $tmpfile
fi
echo "]" >> $tmpfile

echo "" >> $tmpfile
echo "}" >> $tmpfile
mv $tmpfile $pool
