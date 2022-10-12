if [ "$#" -ne 1 ]; then
    echo "Usage: ./create-rtsdn.sh project-name"
    exit 2
fi

# colors
CYAN='\033[1;36m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[0;31m'

# set project name variable
projName=$1

# create a new dotnet project with react template
{
dotnet new react -o $projName 
} || { 
printf "${RED}\nAn error occurred while creating dotnet project${NC}\n"
exit 2
}
cd $projName

# copy important files into temporary folder
tmpCopy=crtdn-tmpCopy-$(date +'%m-%d-%Y-%s-%N')

mkdir ../$tmpCopy
mkdir ../$tmpCopy/tmpSrc
cp ClientApp/.env* ClientApp/aspnetcore-*.js ../$tmpCopy
cp ClientApp/src/setupProxy.js ClientApp/src/serviceWorkerRegistration.js ClientApp/src/service-worker.js ../$tmpCopy/tmpSrc

# remove ClientApp, create react app with tyescript, rename clientapp
rm -rf ClientApp

{
    npx create-react-app clientapp --template typescript
} || { 
   printf "${RED}\nAn error occurred while creating react app.${NC}\n\n"
   rm -rf ../$tmpCopy
   cd ..
   rm -rf $projName
   exit 2
} 
mv clientapp ClientApp 

# copy back the files from tmpCopy and remove tmpCopy
cp ../$tmpCopy/tmpSrc/* ClientApp/src
rm -rf ../$tmpCopy/tmpSrc
cp ../$tmpCopy/* ClientApp
rm -rf ../$tmpCopy

# modify the package.json
sed -i '$s/}/,\n"prestart": "node aspnetcore-https && node aspnetcore-react"}/' ClientApp/package.json

# success output
printf "\n\n************************************************************************\n\n"
printf "${GREEN}Success! You have created an ASP.Net Core app with React TypeScript!\n\n${NC}"
printf "Usage:\n"
printf "    ${CYAN}cd${NC} project-name\n"
printf "    ${CYAN}dotnet run${NC}\n\n"
printf "You may read the official documentation at https://learn.microsoft.com/en-us/visualstudio/javascript/tutorial-asp-net-core-with-react?view=vs-2022.\n\n"
printf "For contributions, improvements to this bash script, or if you found any bugs, go to ${GREEN}https://github.com/raihahahan${NC}.\n\n"
printf "Do ${YELLOW}star${NC} the repository if this was helpful!"
printf "\n\n************************************************************************\n\n"


