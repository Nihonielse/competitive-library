#ifndef INOUT_FILE
#define INOUT_FILE

#include "core.hpp"

inline void yn(const bool &tf) {
    if(tf)cout<<"Yes"<<endl;
    else cout<<"No"<<endl;
}

inline void YN(const bool &tf) {
    if(tf)cout<<"YES"<<endl;
    else cout<<"NO"<<endl;
}

inline void Yes() { cout << "Yes" << endl; }
inline void YES() { cout << "YES" << endl; }
inline void No() { cout << "No" << endl; }
inline void NO() { cout << "NO" << endl; }

template <typename T,typename S>
istream& operator>>(istream& is,pair<T,S>& pa){
    is >> pa.first >> pa.second;
    return is;
}

template <typename T,typename S>
ostream& operator<<(ostream& os,pair<T,S>& pa){
    os << pa.first << " " << pa.second;
    return os;
}

template <typename T>
istream& operator>>(istream& is,vector<T>& vec){
    for(T& item:vec){
        is >> item;
    }
    return is;
}

template <typename T>
ostream& operator<<(ostream& os,vector<T>& vec){
    for(int i=0;i<vec.size();i++){
        if(i) os << " ";
        os << vec[i];
    }
    return os;
}
template <typename T>
ostream& operator<<(ostream& os,vector<vector<T>>& vec){
    for(int i=0;i<vec.size();i++){
        os << vec[i];
        if(i<vec.size()-1)os << endl;
    }
    return os;
}

template <typename T,typename S>
ostream& operator<<(ostream& os,vector<pair<T,S>>& vec){
    for(int i=0;i<vec.size();i++){
        os << vec[i];
        if(i<vec.size()-1)os << endl;
    }
    return os;
}

#endif
