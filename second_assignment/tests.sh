#!/bin/bash


# Created by Ron Even, updated by Amit Grossberg on 2025

TMP_FILE=./tmpfile

DEBUG=0
if [ "$1" == "-d" ]; then
        DEBUG=1
fi

COUNTER=0
FAILED_TESTS=""

declare_step() {
	# echo this with bold, green color, with a newline
	echo -e "\n\033[1;32mTesting $1...\033[0m\n"
}


validate() {
	general_error=0
	COUNTER=$((COUNTER + 1))
	echo "*****************************************"
	printf "$COUNTER"
	cmd="./pstrings <<< \`printf '$1'\`"
	eval "$cmd" > $TMP_FILE 2>/dev/null
	error=$?
	result=`cat $TMP_FILE`
	rm -f $TMP_FILE
	expected=`printf "Enter Pstring length: Enter Pstring: Enter Pstring length: Enter Pstring: Choose a function: \n\t31. pstrlen\n\t33. swapCase\n\t34. pstrijcpy\n\t37. pstrcat\n$2"`
	if [ $error -ne 0 ]
	then
		 echo -e "\t\t❌ FAILED"
                echo -e "$1\n"
                echo -e "Return code was $error and not 0! Make sure the program doesn't crash"
				FAILED_TESTS+="$COUNTER,"
                general_error=1
		 return
	fi

        if [ "$result" == "$expected" ]
        then
                echo -e "\t\t✅ PASSED"
	        #echo -e "$1"
        else
				FAILED_TESTS+="$COUNTER,"
				general_error=1
                echo -e "\t\t❌ FAILED\n"
                echo -e "$1\n"
                echo -e "Expected:\n$expected\n"
                if [ $DEBUG -eq 1 ]; then
                        echo -e "Expected as hex:"
                        echo -e $expected | hexdump -C
                        printf "\n"
                fi
                echo -e "Got:\n$result\n"
                if [ $DEBUG -eq 1 ]; then
                        echo -e "Got as hex:"
                        echo -e $result | hexdump -C
                fi
        fi
}

if [ -f pstrings ]
then
	# INVALID OPTIONS
	declare_step "Invalid options"
	validate "2\nab\n2\nna\n49" "invalid option!"
	validate "2\nab\n2\nna\n20" "invalid option!"
	validate "2\nab\n2\nna\n32" "invalid option!"
	validate "3\nabc\n4\nabcd\n59" "invalid option!"
	validate "5\nhello\n5\nworld\n42" "invalid option!"
	validate "5\nhello\n5\nworld\n51" "invalid option!"
	validate "5\nhello\n5\nworld\n71" "invalid option!"
	
	# PSTRING LENGTH: In 2021 was 50/60, in 2023 is 31
	declare_step "pstrlen (31)"
	validate "6\nhelloo\n7\nooooooa\n31" "first pstring length: 6, second pstring length: 7"
	validate "1\na\n2\nab\n31" "first pstring length: 1, second pstring length: 2"
	validate "6\nhelloo\n7\nooooooa\n31" "first pstring length: 6, second pstring length: 7"
	validate "5\nhello\n5\nworld\n31" "first pstring length: 5, second pstring length: 5"
	validate "6\nhello!\n5\nworld\n31" "first pstring length: 6, second pstring length: 5"
	
	# # CHAR REPLACEMENT: In 2021 was 52, in 2023 is 32/33
	# validate "21\ncomputer_organization\n3\nfan\n32\na u" "old char: a, new char: u, first string: computer_orgunizution, second string: fun"
	# validate "6\nhello!\n5\nworld\n32\nl z" "old char: l, new char: z, first string: hezzo!, second string: worzd"
	# validate "11\nOfrA_keAdar\n5\nAmmmA\n32\nA i" "old char: A, new char: i, first string: Ofri_keidar, second string: immmi"
	# validate "6\nhello!\n5\nworld\n33\ne @" "old char: e, new char: @, first string: h@llo!, second string: world"
	# validate "6\nhello!\n5\nworld\n33\n! [" "old char: !, new char: [, first string: hello[, second string: world"
	# validate "6\nhello!\n5\nworld\n33\no 0" "old char: o, new char: 0, first string: hell0!, second string: w0rld"

	# swapCase: In 2021 was 54, in 2023 is 33
	declare_step "swapCase (33)"
	validate "5\nh@LL!\n11\nG@L@K@MiNk@\n33" "length: 5, string: H@ll!\nlength: 11, string: g@l@k@mInK@"
	validate "5\naB={]\n5\nAb=[}\n33" "length: 5, string: Ab={]\nlength: 5, string: aB=[}"
	validate "10\naAbBcC@!dD\n13\nfk309u2+~_dsa\n33" "length: 10, string: AaBbCc@!Dd\nlength: 13, string: FK309U2+~_DSA"
	
	# pstrijcpy: In 2021 was 53, in 2023 was 35, in 2025 is 34
	declare_step "pstrijcpy (34)"
	validate "6\nhello!\n5\nworld\n34\n0 5" "invalid input!\nlength: 6, string: hello!\nlength: 5, string: world"
	validate "8\nhello_we\n3\nabc\n34\n0 2" "length: 8, string: abclo_we\nlength: 3, string: abc"
	validate "8\nhello_we\n3\nabc\n34\n1 4" "invalid input!\nlength: 8, string: hello_we\nlength: 3, string: abc"
	validate "6\nhello!\n5\nworld\n34\n0 0" "length: 6, string: wello!\nlength: 5, string: world"
	validate "5\nhello\n5\nworld\n34\n1 4" "length: 5, string: horld\nlength: 5, string: world"
	validate "5\nhello\n5\nworld\n34\n4 4" "length: 5, string: helld\nlength: 5, string: world"
	validate "5\nhello\n5\nworld\n34\n0 9" "invalid input!\nlength: 5, string: hello\nlength: 5, string: world"
	validate "6\npickle\n4\nrick\n34\n0 3" "length: 6, string: rickle\nlength: 4, string: rick"
	validate "4\nrick\n6\npickle\n34\n0 3" "length: 4, string: pick\nlength: 6, string: pickle"
	validate "4\nerez\n4\nrick\n34\n0 3" "length: 4, string: rick\nlength: 4, string: rick"
	validate "4\nerez\n4\nrick\n34\n3 8" "invalid input!\nlength: 4, string: erez\nlength: 4, string: rick"
	validate "4\nerez\n4\nrick\n34\n2 1" "invalid input!\nlength: 4, string: erez\nlength: 4, string: rick"
	
	# # pstrijcmp: In 2021 was 55, in 2023 was 37, in 2025 was removed
	# validate "4\naaaa\n3\naab\n37\n1\n2" "compare result: -1"
	# validate "7\nddehllo\n4\nfffb\n37\n1\n3" "compare result: -1"
	# validate "4\navba\n3\naab\n37\n1\n2" "compare result: 1"
	# validate "12\n!&amp;m@uteR\n8\nBBm@utAA\n37\n3\n7" "compare result: 1"
	# validate "16\njkglasdfaavgfdba\n15\njkcdkpadaafdsaf\n37\n8\n9" "compare result: 0"
	# validate "5\nhello\n5\ndello\n37\n1\n4" "compare result: 0"
	# validate "5\nhello\n5\nhello\n37\n1\n2" "compare result: 0"
	# validate "16\njkglasdfaavgfdba\n2\naa\n37\n8\n9" "invalid input!\ncompare result: -2"
	# validate "3\ndba\n10\nasdfasdfaa\n37\n8\n9" "invalid input!\ncompare result: -2"
	# validate "5\nhello\n5\nworld\n37\n1\n10" "invalid input!\ncompare result: -2"
	# validate "2\nAa\n2\naA\n37\n0\n0" "compare result: -1"
	# validate "3\naba\n2\nab\n37\n0\n1" "compare result: 0"

	# pstrcat: added in 2025 is 37
	declare_step "pstrcat (37)"
	validate "5\nhello\n5\nworld\n37" "length: 10, string: helloworld\nlength: 5, string: world"
	validate "1\na\n1\nb\n37" "length: 2, string: ab\nlength: 1, string: b"
	validate "4\nRick\n5\nMorty\n37" "length: 9, string: RickMorty\nlength: 5, string: Morty"
	validate "6\nPotato\n6\nTomato\n37" "length: 12, string: PotatoTomato\nlength: 6, string: Tomato"
	validate "3\nBob\n7\nBuilder\n37" "length: 10, string: BobBuilder\nlength: 7, string: Builder"
	validate "5\nShrek\n5\nFiona\n37" "length: 10, string: ShrekFiona\nlength: 5, string: Fiona"
	validate "8\nChandler\n6\nMonica\n37" "length: 14, string: ChandlerMonica\nlength: 6, string: Monica"
	validate "3\nTom\n5\nJerry\n37" "length: 8, string: TomJerry\nlength: 5, string: Jerry"
	validate "9\nSpongebob\n7\nPatrick\n37" "length: 16, string: SpongebobPatrick\nlength: 7, string: Patrick"
	validate "99\nDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDog\n17\nWhatDoesTheFoxSay\n37" "length: 116, string: DogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogDogWhatDoesTheFoxSay\nlength: 17, string: WhatDoesTheFoxSay"
	validate "252\nCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCat\n11\nFelixTheCat\n37" "cannot concatenate strings!\nlength: 252, string: CatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCatCat\nlength: 11, string: FelixTheCat"

else
	echo "❌ Couldn't find pstrings file!"
fi

echo ""
        echo "************ 📝  SUMMARY  📝 ************"
        failed_count=$(echo $FAILED_TESTS | tr -cd ',' | wc -c)
        success_count=$((COUNTER-failed_count))
        echo "           $success_count/$COUNTER tests passed!"
        if [ $success_count -ne $COUNTER ]
        then
            echo "Failed tests are:"
            FAILED_TESTS=${FAILED_TESTS%?}
            echo $FAILED_TESTS
        fi

echo ""
echo "****************************************************"
echo "** Created by Ron Even, Updated by Amit Grossberg **"
echo "****************************************************"
