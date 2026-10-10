#include <iostream>
#include <filesystem>
#include <fstream>
#include <regex>
#include <cstdlib>

namespace fs = std::filesystem;

int main(int argc, char* argv[]){
    if (argc == 0){
        std::cerr << "No input file" << std::endl;
        return 1;
    }
    std::string file_path = argv[1];

    std::string comp_path = "build/comp-";
    std::regex pattern("([^/]*\\.cpp)");
    std::smatch match;
    if(!std::regex_search(file_path,match,pattern)){
        std::cerr << "Error: File name must be \"*.cpp\"" << std::endl;
        return 1;
    }
    std::string file_name = match[0];
    comp_path += file_name;
    std::string subm_path = "build/submittion-" + file_name;
    std::cout<< "Test File: " << file_path <<std::endl;

    if(!fs::exists(file_path)){
        std::cerr << "Error: File not found" << std::endl;
        return 1;
    }

    bool modified = false;
	int result = std::system(("/home/nihoel/.local/bin/oj-bundle " + file_path + " > ./build/submittion-" + file_name).c_str());
	if(WEXITSTATUS(result) != 0){
		std::cout << "oj-bundle FAILED." << std::endl;
		return 1;
	}
    if(!fs::exists(comp_path)){
        modified = true;
    }

    if(!modified && fs::file_size(subm_path) != fs::file_size(comp_path)) {
        modified = true;
    }

    if(!modified){

		modified = fs::file_size(subm_path) != fs::file_size(comp_path);
	}

	if(!modified){
		std::ifstream target_file(subm_path);
		std::ifstream source_file(comp_path);

        std::string line1,line2;
        int i=1,j=1;

        while (i++ && std::getline(target_file, line1) && j++ && std::getline(source_file, line2)) {
            if (line1 != line2) {
                modified = true;
                break;
            }
        }
        if(i>j){
            if(std::getline(source_file, line2)){
                modified = true;
            }
        }
    }


    if(modified) {
        std::cout << "File is modified. Compiling..." << std::endl;

        std::system(("wl-copy < ./build/submittion-" + file_name).c_str());

        int result = std::system(("g++ -std=c++23 -I . -O0 -DDEBUG_LOG -fuse-ld=mold -g -fsanitize=address,undefined " + file_path + " -o " + comp_path + "-bin").c_str());
        if (WEXITSTATUS(result) == 0) {
            std::cout << "Compile finished." << std::endl;
            fs::copy_file(subm_path, comp_path, fs::copy_options::overwrite_existing);
        } else {
            std::cerr << "Compile FAILED." << std::endl;
            return 1;
        }
    } else {
        std::system(("wl-copy < ./build/submittion-" + file_name).c_str());
        std::cout << "File isn't modified." << std::endl;
    }
    return 0;
}
