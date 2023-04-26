/*#########################################
## 06/02/2023
## Par Elyna Bouchereau
## Fichier: mutate_seq.cpp
###########################################*/
#include <iostream>
#include <fstream>
#include <iomanip>
#include <string>
#include <algorithm>
#include <random>
#include <bits/stdc++.h> 
#include <ctime>

using namespace std;


struct residues{
	char liste_aa[20] = {'A','C','D','E','F',
					'G','H','I','K','L',
					'M','N','P','Q','R',
					'S','T','W','Y','V'};
	float list_proba[20];
};
//****************************************************************
/*
	A simple random generator for making dummy triangular matrix.
*/
int random_val(int max){
	random_device rd;
	mt19937 gen(rd());
	uniform_int_distribution<> distr(0,max);
	return distr(gen);
}
//******************************************************************************
template <typename T> string to_str(const T& t) { 
   ostringstream os; 
   os<< t << setprecision(2) ; 
   return os.str(); 
} 
int input()
{
	string entree = "";
	cin >> entree;
	try{
		stoi(entree);
	} catch(exception &err){
		return 0;
	}
	return stoi(entree);
}

bool choice(){
	if(random_val(100) > 80) return true;
	else return false;
}
string mutate(string sequence, const char* liste_aa){
	for(int i=0; i<sequence.size();i++){
		if(random_val(100)>80){
			sequence[i] = liste_aa[random_val(19)];
		}
	}
	return sequence;
}

string generate_seq(int nb_seq,string sequence_ref, const char* liste_aa){
	string seq, list_seq = "";
	list_seq = ">Sequence_mutated_1\n" + sequence_ref + "\n";
	for(int n=1;n<nb_seq;n++){
		seq = ">Sequence_mutated_" + to_str<int>(n+1) + "\n";
		seq += mutate(sequence_ref, liste_aa);
		list_seq += seq + "\n";
	}
	return list_seq;
}
//################################################################################## Doh, Calligraphy, Broadway, Fraktur, Poison
/*                                                                                                                   
     *****   **    **           **                *****  *      ***** *     **    
  ******  ***** *****        *****             ******  *     ******  **    **** * 
 **   *  *  ***** *****     *  ***            **   *  *     **   *  * **    ****  
*    *  *   * **  * **         ***           *    *  *     *    *  *  **    * *   
    *  *    *     *           *  **              *  *          *  *    **   *     
   ** **    *     *           *  **             ** **         ** **    **   *     
   ** **    *     *          *    **            ** **         ** **     **  *     
   ** **    *     *          *    **          **** **         ** **     **  *     
   ** **    *     *         *      **        * *** **         ** **      ** *     
   ** **    *     **        *********           ** **         ** **      ** *     
   *  **    *     **       *        **     **   ** **         *  **       ***     
      *     *      **      *        **    ***   *  *             *        ***     
  ****      *      **     *****      **    ***    *          ****          **     
 *  *****           **   *   ****    ** *   ******          *  *****              
*     **                *     **      **      ***          *     **               
*                       *                                  *                      
 **                      **                                 **                    
*/



int main(int argc, char *argv[]){
	const int nb_seq = stoi(argv[1]);
	string sequence = argv[2];
	string list_seq;
	char liste_aa[] = {'A','C','D','E','F',
						'G','H','I','K','L',
						'M','N','P','Q','R',
						'S','T','W','Y','V'};
	//ofstream file_out(argv[1]);
	//cout << "Liste de séquences random de "<< sequence.size() <<" acides aminés:\n";
	//cout << "==================================================\n";
	cout << generate_seq(nb_seq,sequence, liste_aa)	;
}