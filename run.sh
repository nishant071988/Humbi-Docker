# Check if two argument has been passed

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source> <destination_to_copy>"
    exit 1
fi

source_path="$1"

# Installing unzip 
apt install unzip

exe_path="/tmp/4icli_scripts/"
# Check if the directory exists

if [ -d "$exe_path" ]; then
    echo "Directory $exe_path already exists."
else
    echo "Directory $exe_path does not exist. Creating now."
    mkdir -p $exe_path
    if [ $? -ne 0 ]; then
        echo "Failed to create directory."
        exit 1
    fi
fi
#Copy the file to exe_path

for file in "$source_path"*; do
    # Check if the current item is a file
    if [ -f "$file" ]; then
        cp -p "$file" "$exe_path"
    fi
done

cd /tmp/4icli_scripts || exit

#./4icli datahub --apm=D0333 --category="Beneficiary List" --createdWithinLastWeek --download 
#./4icli datahub --apm=D0333 --category=Reports --createdWithinLastWeek --download
./4icli datahub --apm=D0333 --category=CCLF --createdWithinLastMonth --view > log.txt
./4icli datahub --apm=D0333 --category=CCLF --createdWithinLastMonth --download

zip_name=$(grep -o '[^ ]*.zip' log.txt)

# Creating folder to unzip files
unzip_path=/tmp/cclf/
if [ -d "$unzip_path" ]; then
    echo "Directory $unzip_path already exists."
else
    echo "Directory $unzip_path does not exist. Creating now."
    mkdir -p $unzip_path
    if [ $? -ne 0 ]; then
        echo "Failed to create directory."
        exit 1
    fi
fi

mv $zip_name /tmp/cclf/
cd /tmp/cclf/
unzip  $zip_name

# Copy zip files to azure storage container
dest_path="$2"
cclf_dest_path=$dest_path'cclf/'
for file in /tmp/cclf/*; do
    echo "Uploading $file to Azure Storage..."
    rsync --ignore-existing "$file" "$cclf_dest_path"
done

#Copy files to azure storage container

cd /tmp/4icli_scripts
./4icli datahub --apm=D0333 --category="Beneficiary List" --createdWithinLastWeek --download
exclude_files=("4icli" "config.txt" "log.txt")

beneficiary_path=$dest_path'beneficiary/'
for file in /tmp/4icli_scripts/*; do
    filename=$(basename "$file")
    if [[ " ${exclude_files[@]} " =~ " ${filename} " ]]; then
        echo "Skipping upload for excluded file: $filename"
    else
    echo "Uploading $file to Azure Storage..."
    rsync --ignore-existing "$file" "$beneficiary_path"
    fi
done

# Delete the files
find /tmp/4icli_scripts/ -type f | grep -vE '(4icli|config\.txt|log\.txt)$' | xargs rm -rf

./4icli datahub --apm=D0333 --category=Reports --createdWithinLastWeek --download

exclude_files=("4icli" "config.txt" "log.txt")

reports_path=$dest_path'reports/'
for file in /tmp/4icli_scripts/*; do
    filename=$(basename "$file")
    if [[ " ${exclude_files[@]} " =~ " ${filename} " ]]; then
        echo "Skipping upload for excluded file: $filename"
    else
    echo "Uploading $file to Azure Storage..."
    rsync --ignore-existing "$file" "$reports_path"
    fi
done

rm -rf /tmp/cclf/
rm -rf /tmp/4icli_scripts
