echo "BlackPearl Tape Verify Script, used to verify a generation of tapes in a bucket"

echo "Enter name of environmental setup file and extension Example: setup.sh"
read setup_file

echo "Type in Bucket to Verify"
read bucket_name
echo "Enter generation you want to verify.....Example: L7"
read gen
 
echo "Now working on this bucket and finding all tapes, excluding all other generations other than the one you asked for.....Standby please"

source $setup_file

./ds3_java_cli -c get_tapes -b $bucket_name --http --output-format json > output.json 

grep '"BarCode"\|"LastVerified\|"VerifyPending"' output.json |  tr -d '"BarCode" : , astVerified, VerifyPeding' > barcode.txt  

if [ -s barcode.txt ]; then

   echo "Finding what tapes need to be verified"

   IFS=$'\n' read -d '' -r -a lines < barcode.txt
        
   vfy_null=1
   vfy_low=2
   tape=0
   rm tapes_to_verify.txt

   for (( j=0; j<${#lines[@]}; j++ ));
      do
        echo ${lines[@]} >> output.txt
        if [[ ${lines[vfy_null]} == "Lull" &&  ${lines[vfy_low]} == "ull" ]]; then                
          #   echo ${lines[$tape]}
          #   echo ${lines[@]}
              echo ${lines[$tape]} >> tapes_to_verify.txt
        fi 
           vfy_null=$((vfy_null+3))
           vfy_low=$((vfy_low+3))
           tape=$((tape+3))
   done
   
     if [ -s tapes_to_verify.txt ]; then
   
      echo "Removing all other generation of tapes from list"      
      grep "$gen" tapes_to_verify.txt > sorted_tapes_to_verify.txt
   
      if [ -s sorted_tapes_to_verify.txt ]; then
         for i in $(cat ./sorted_tapes_to_verify.txt);
            do
             echo "Sending verify jobs now"
             #sh ./ds3_java_cli -c verify_tape -i $i --http 
             #echo $i
          done
       else 
          echo "No tapes identified as needing a verify"
       fi
   else
      echo "No tapes identified as needing a verify"
   fi 
     
else
   echo "No file found"
fi
