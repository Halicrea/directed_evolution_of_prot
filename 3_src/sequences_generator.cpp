/*#########################################
## 06/02/2023
## Par Elyna Bouchereau
## Fichier: sequences_generator.cpp
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
	// Probability of residue apparition based on the reference sequence
	// and it's homologues.
	float list_proba[20] = {0.06325816,0.06325817,0.13438267,0.23488231, 0.26824496,
      						0.35204942,0.35387318,0.37620385,0.57912325, 0.63169239,
      						0.6673402 ,0.68510781,0.70857485,0.71446683, 0.76918607,
     						0.81360307,0.8282362 ,0.85870224,0.95568897};
							
	/*float list_proba[20] = {0.063258160,0,0.071124511,0.100499639,
							0.033362653,0.083804456,0.001823763,
							0.022330665,0.202919398,0.052569144,
							0.035647807,0.017767616,0.023467039,
							0.005891983,0.054719231,0.044417009,
							0.014633130,0.030466040,0.096986725};*/
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
float random_val(float max){
	random_device rd;
	mt19937 gen(rd());
	uniform_real_distribution<> distr(0,max);
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

string generate_seq(int nb_seq,int size_seq, ofstream &file_out, const char* liste_aa, residues list_aa_struct){
	const float sum_weight = 0.95568897;

	string seq, list_seq = "";
	for(int n=0;n<nb_seq;n++){
		seq = ">Sequence_random_" + to_str<int>(n+1) + "\n";
		for(int i=0;i<size_seq;i++){
			// We search a AA in the table. If the random value
			float rnd = random_val(sum_weight);
			for(int aa=0;aa<20;aa++){
				if(rnd < list_aa_struct.list_proba[aa]){
					seq += liste_aa[aa];break;
				}
			}
			//rnd -= list_aa_struct.list_proba[i];
		}
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
	const int nb_seq = stoi(argv[2]);
	const int size_seq = stoi(argv[3]);
	string list_seq;
	char liste_aa[] = {'A','C','D','E','F',
						'G','H','I','K','L',
						'M','N','P','Q','R',
						'S','T','W','Y','V'};
	residues list_aa_struct;
	ofstream file_out(argv[1]);
	file_out << "Liste de séquences random de 66 acides aminés:\n";
	file_out << "==================================================\n";
	list_seq = generate_seq(nb_seq,size_seq, file_out, liste_aa, list_aa_struct);
	file_out << list_seq;
	file_out.close();
}