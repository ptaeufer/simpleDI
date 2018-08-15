cd ..
pool=$(find ${PWD} -name "Injector.swift")

write_enum()
{
  echo "" >> $pool
  echo "extension Injector {" >> $pool
  echo "" >> $pool
  echo "    enum $1 : String {" >> $pool
  echo "" >> $pool
  _contents="${2}"
  shift
  local _contents=("${@}")
  echo ${_contents[@]}
  for case in ${_contents[@]}; do
  echo "        case "$case >> $pool
  done
  echo "        case none" >> $pool
  echo "static func fromClassName(_ name : String) -> classes {
            return Injector.classes(rawValue : name) ?? .none
        }" >> $pool
  echo "" >> $pool
  echo "    }" >> $pool
  echo "" >> $pool
  echo "}" >> $pool
}

if [[ -z "$pool" ]]
then
echo "skip"
else
>$(find ${PWD} -name "Injector.swift")

echo "import Foundation" >> $pool
echo "" >> $pool
echo "class Injector{" >> $pool


echo "   public static let dependencies : Dictionary<Injector.classes,()->AnyObject> = [" >> $pool
dependenciesFound=0
for file in $(find ${PWD} -name "*.swift"); do
#sed -i '' -e 's/class / open class /g' $file
for name in $(cat $file | grep "class" | sed -n 's/.*class *\(.*\) *: *DependencyModule.*/\1/p' | sort -u); do

sed -i '' -e 's/private//g' $file
sed -i '' -e 's/lazy var /var /g' $file
sed -i '' -e 's/var /let /g' $file
sed -i '' -e 's/let /static let /g' $file
sed -i '' -e 's/func /static func /g' $file
sed -i '' -e 's/static static func / static func /g' $file
sed -i '' -e 's/static static let / static let /g' $file

contents=$(cat $file | grep "static let" | sed -n 's/.*static let *\([a-zA-Z0-9_\-]*\) *: *\([a-zA-Z0-9_\-]*\) *.*=.*/\1|\2/p')

contents_func=$(cat $file | grep "static func" | sed -n 's/.*static func *\([a-zA-Z0-9_\-]*\) *.*> *\([a-zA-Z0-9_\-]*\) *.*/\1|\2/p')

classes=()

for _name in $contents_func; do
echo $_name
dependenciesFound=$((dependenciesFound+1))
var1=${_name%|*}
var2=${_name#*|}
classes+=" $var2"
echo ".$var2 : $name.$var1," >> $pool
done

for _name in $contents; do
echo $_name
dependenciesFound=$((dependenciesFound+1))
var1=${_name%|*}
var2=${_name#*|}
classes+=" $var2"
echo ".$var2 : { return $name.$var1 }," >> $pool
done
done
done

if [[ "$dependenciesFound" -eq 0 ]]
then
echo "        :" >> $pool
fi
echo "]" >> $pool

echo "" >> $pool
echo "}" >> $pool
write_enum "classes" $classes

echo "open class DependencyModule{}

func inject<T>() -> T {
    return inject(String(describing : T.self))
}

func inject<T>(_ c : AnyClass) -> T {
    return inject(String(describing : c))
}

private func inject<T>(_ name : String) -> T {
    
    if let dep : ()->AnyObject =  Injector.dependencies[Injector.classes.fromClassName(name)], let obj = dep() as? T {
        return obj
    }
    fatalError(\"dependency for \(name).self not found\")
}" >> $pool;
fi



