################################
# ///    Script By BROLY   \\\#
## ---------->157<---------- ##
################################

##COLORS

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
RESET=`tput sgr0`

#########
SECONDS=0
#########
QUOTES=("Grab a cup of COFFEE!")


printf "${GREEN}

██████╗ ██████╗  ██████╗ ██╗  ██╗   ██╗
██╔══██╗██╔══██╗██╔═══██╗██║  ╚██╗ ██╔╝
██████╔╝██████╔╝██║   ██║██║   ╚████╔╝
██╔══██╗██╔══██╗██║   ██║██║    ╚██╔╝
██████╔╝██║  ██║╚██████╔╝███████╗██║
╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝

                        ${MAGENTA}--by Broly157
${RESET}"

printf "${BLUE}[i]${RESET}${RED}${QUOTES[$rand]}${RESET}\\n"
echo

##API KEYS##
securitytrails_key='jp9CslVyzOXNi8nQ3YPD5vrvxqUupyP0'
virustotal_key='b44bd8d74272d806556c3aae24fc009723fb93bdf18b35d3bdb609df95067d08'
chaos_key='4fc7c0da749de6a402c5f1bcf6d3c7793806996f090ecdec0920971426e0adbe'
gitoken='f3190a0368cc004aec66e87de484c560c0839da2'
##TEXT FILES##
pwords=/usr/share/wordlist/pwords.txt
sresolver=/usr/share/wordlist/resolvers.txt

#-------------------------------------------------------------------------------------------------------#
#Alias for Folder's

target=~/recondata/automatd/$1
findings=$target/findings
final=$target/final


#-------------------------------------------------------------------------------------------------------#

domain=$1

mkdir $target

mkdir $target/findings

mkdir $target/final

cd $findings

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mAmass Scanning started\e[0m"
#       amass enum --passive -d $1 -o amass.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mFindomain Scanning started\e[0m"
        findomain -t $1 -u findomain.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mAssetfinder Scanning started\e[0m"
        assetfinder --subs-only $1 | tee -a asset.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSubfinder Scanning started\e[0m"
        subfinder -d $1 | tee -a subfinder.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mChaos Scanning started\e[0m"
        chaos -key $chaos_key -d $1 -silent | tee -a chaos.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCensys Scanning started\e[0m"
        python3 ~/tools/censys-subdomain-finder/censys_subdomain_finder.py $1 -o censys.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCrobat Rapid7 FDNS Scanning started\e[0m"
        crobat -s $1 | tee -a crobat.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mGithub-Scanning started$\e[0m"
        python3 ~/tools/github-search/github-subdomains.py -e -t $gitoken -d $1 | egrep '$1' | tee -a gitsub.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSublist3r Scanning started$\e[0m"
        python3 ~/tools/Sublist3r/sublist3r.py -v -t 15 -d $1 -o sublist3r.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCrt.sh Scanning started\e[0m"
        curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a crt.txt
        cat crt.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee -a crtsh.txt ; rm crt.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mJLDC.me Scanning started\e[0m"
        curl -s "https://jldc.me/anubis/subdomains/$1" | grep -Po '((http|https):\/\/)?(([\w.-]*)\.([\w]*)\.([A-z]))\w+' | tee -a jldc.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mRapiddns.io Scanning started\e[0m"
        curl -s "https://rapiddns.io/subdomain/$1?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u | tee -a rapidns.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mBufferOverflow Scanning started\e[0m"
        curl -s --request GET --url "dns.bufferover.run/dns?q=.$1&rt=5" | jq --raw-output '.FDNS_A[]' | awk '{print $1}' | sed -e 's/^.*,//g' | sort -u | tee -a bufferover.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSearching in the SecurityTrails API...\e[0m"
        curl -s --request GET --url "https://api.securitytrails.com/v1/domain/$1/subdomains?apikey=$securitytrails_key" | jq --raw-output -r '.subdomains[]' | tee garbage.txt
        for i in $(cat garbage.txt); do echo $i'.'$1; done | tee -a securitytrails.txt
        rm -rf garbage.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCertspotter Scanning started\e[0m"
        curl -s https://certspotter.com/api/v0/certs?domain=$1 | jq -c '.[].dns_names' | grep -o '"[^"]\+"' | tr -d '"' | sort -fu | grep "$1" | tee  certspotter.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mThreatcrowd Scanning started\e[0m"
        curl https://www.threatcrowd.org/searchApi/v2/domain/report/\?domain=$1 | jq '.subdomains' | sed 's/[][\/$*^|@#{}~&()_:;%+"='\'',`><?!]/ /g' | awk '{print $1}' | tee threatcrowd.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mHackertarget Scanning started\e[0m"
        curl https://api.hackertarget.com/hostsearch/\?q\=$1 | cut -d "," -f 1 | tee hackertarget.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mVirustotal Scanning started\e[0m"
        curl --silent --request GET --url "https://www.virustotal.com/vtapi/v2/domain/report?apikey=$virustotal_key&domain=$1" | jq --raw-output -r '.subdomains[]?' | sort -u  | tee virustotal.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCreating Allrootdomains.txt\e[0m"
#       cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee allrootsubdomains.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMassdns Scanning started\e[0m"
#       massdns -r $resolver -t A -o S -w massdns.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mExtracting subdomains from massdns.txt\e[0m"
#       sed 's/A.*//' massdns.txt | sed 's/CN.*//' | sed 's/\..$//' | tee subdomain_massdns.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mRemoving massdns.txt\e[0m"
#       rm massdns.txt && rm allrootsubdomains.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMaking all.txt\e[0m"
        cat *.txt | sort -u > all.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mStarting ShuffleDns Subdomain Enumeration $\e[0m"
        shuffledns -d $1 -list $findings/all.txt -r ~/tools/massdns/lists/resolvers.txt -o shuffledns.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMaking all.txt\e[0m"
        cat all.txt shuffledns.txt | sort -u | grep -v "*" | tee all.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96m${YELLOW}Starting DNSgen Scan in 10 sec. Type {N/n} to skip ${BLUE}{y${BLUE}}:$\e[0m"
for i in {10..1}
do
    read -t .1 -n 1 input
    if [  "$i" = "1"  ]; then
    printf "\n${RED}Dnsgen started \n${RESET}" && dnsgen -l 6 -f -w ~/wordlists/assetnote/best-dns-wordlist.txt all.txt | shuffledns -r ~/tools/massdns/lists/resolvers.txt -o dnsgen_all.txt

    elif [  "$input" = "n"  ]; then
    printf "\n Skipping Dnsgen scan \n"
        break
    fi
    echo -ne "\n $i \r" && sleep 1;
done

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCreating Allrootdomains.txt\e[0m"
#       cat *.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | tee $final/3rd_Level_subdomains.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mRemoving all.txt\e[0m"
#       rm all.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMaking Fresh final (all.txt)\e[0m"
        cd $findings
        cat all.txt dnsgen_all.txt | sort -u | grep -v "*" | egrep $domain | tee total_subdomains.txt

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96mStarting ShuffleDns\e[0m"
#       shuffledns -d $1 -list temp_all.txt -r ~/tools/massdns/lists/resolvers.txt | tee temp_all1.txt ; cat temp_all.txt temp_all1.txt | sort -u | tee all.txt ; rm temp_all.txt temp_all1.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mMoving files to final folder$\e[0m"
        mv ./total_subdomains.txt ../final/
        cd $final

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mChecking for alive domains\e[0m"
        cat total_subdomains.txt | sort -u | httpx -timeout 5 -threads 300 -retries 1 -ports 80,443,8009,8080,8081,8090,8180,8443 -content-length -status-code -silent -o alive_detailed.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mOKAY these are the final Alive domains\e[0m"
        cat alive_detailed.txt | cut -d : -f-2 > alive.txt
        count=$(cat alive.txt | sort -u | wc -l)

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mFound: $count Alive Subdomain's\e[0m"

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mSorting Subdomains by Status Codes\e[0m"
        mkdir subdomains_sorted && cd subdomains_sorted
        cat ../alive_detailed.txt| egrep '400|401|402|403|404|405' | cut -d : -f-2 > 400.txt
        cat ../alive_detailed.txt| egrep '200|201|202|203|204|205' | cut -d : -f-2 > 200.txt
        cat ../alive_detailed.txt| egrep '300|301|302|304|307|308' | cut -d : -f-2 > 300.txt
        cat ../alive_detailed.txt| egrep '500|501|502|503|504|505' | cut -d : -f-2 > 500.txt
        cd ..

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mDetecting Tech on Subdomains using Wappalyzer Started$\e[0m"
        webanalyze -hosts alive.txt -silent | tee -a subs_wappalyzer.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mDetecting WAFs on Subdomains$\e[0m"
        wafw00f -a -i alive.txt -o subs_waf.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mAquatone Started$\e[0m"
        mkdir screenshots
        cat alive.txt | aquatone -out ./screenshots/$1 -threads 50 -screenshot-timeout 50000

        mkdir dns
echo -e "\e[5m\e[1m${BLUE}[+]\e[96mCNAME Scanning Started\e[0m"
        dnsprobe -l alive.txt -r CNAME | tee -a ./dns/domain-cnames

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mGetting IP Addresses for Each Alive Host\e[0m"
        dnsprobe -l alive.txt | sort -u | tee -a ./dns/domain-ips

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mJScanning started\e[0m"
        JSfileScanner.sh

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mfinding Subdomains using CSP\e[0m"
        cat $final/alive.txt | csp -c 20 | tee -a temp_csp.txt
        cat temp_csp.txt | grep "$domain" | tee ./subdomains_sorted/subs_from_csp.txt ; rm temp_csp.txt

cd $target

#prompt_confirm() {
#  while true; do
#    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
#    case $REPLY in
#      [yY]) cat $findings/*.txt | sort -u | tee -a final/total_subs.txt && rm -fr $findings/ ; return 0
#        ;;
#      [nN]) echo ; return 1 ;;
#      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
#    esac
#  done
#}

#prompt_confirm "${BLUE}[+] ${YELLOW}Do you want to combine every file in findings folder? if {y/Y} then you will only have one folder i.e [final] with everything${RESET}"

#echo -e ' '

cd $final

echo -e ' '

#echo -e "\e[5m\e[1m${BLUE}[+]\e[96m${YELLOW}Plain massdns Scanning\e[0m"
#       massdns -r $resolver -w massdns-op.txt $final/total_subs.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mBypassing Subdomains with 400 status code\e[0m"
        cat ./subdomains_sorted/400.txt | while read i ; do byp455 $i | egrep curl | sort -u | tee ./subdomains_sorted/400_bypassed.txt; done && if [ ! -s ./subdomains_sorted/400.txt ]; then echo "The tool worked but didn't Found Any Bypass" >> ./subdomains_sorted/400_bypassed.txt;else echo "You got some bypass in 400_bypassed.txt";fi; return 0

echo -e ""

#prompt_confirm() {
#  while true; do
#    read -r -n 1 -p "${1:-Continue?} [y/n]: " REPLY
#    case $REPLY in
#      [yY]) printf "\nScanning For Broken-Links\n" && cat alive.txt | while read i ; do broken-link-checker -rofi --filter-level 3 $i | egrep BROKEN | sort -u | tee blc; done ; return 0
#       ;;
#      [nN]) echo ; return 1 ;;
#      *) printf " \033[31m %s \n\033[0m" "Bruh..Only {Y/N}"
#    esac
#  done
#}

#prompt_confirm "${BLUE}[+] ${YELLOW}Do you wanna Check for Broken-Link-HighJacking?${RESET}"

echo -e ""

echo -e "\e[5m\e[1m${BLUE}[+]\e[96m Checking Subdomamin Takeovers\e[0m"
        mkdir $final/subtake && cd $final/subtake
        subjack -w ../alive.txt -t 100 -timeout 30 -o subjack.txt -ssl
        subzy -targets ../alive.txt -concurrency 1000 -timeout 30 -hide_fails | tee subzy.txt
        python3 ~/tools/subdover/subdover.py -l ../alive.txt -t 1000 -o subdover.txt
        cat *.txt > takeovers.txt
        rm subjack.txt subzy.txt subdover.txt
        cd ..

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mScanning For CORS\e[0m"
        cd $final
        mkdir $final/cors
        cat alive.txt | CorsMe -t 70 -wildcard -output ./cors/cors.txt

echo -e "\e[5m\e[1m${BLUE}[+]\e[96mNuclei Scanning\e[0m"
        cd $final
        mkdir $final/nuclei
        cat alive.txt | nuclei -t ~/nuclei-templates -exclude ~/nuclei-templates/fuzzing/basic-auth-bruteforce.yaml -o nuclei/nuclei.txt


duration=$SECONDS

printf "${GREEN}[+]${CYAN} Scan is completed in : $(($duration / 60)) minutes and $(($duration % 60)) seconds.${RESET}\n"
exit