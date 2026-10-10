#ifndef OTHERS_FILE
#define OTHERS_FILE
#include "core.hpp"

// prefix_sumは2次元まで対応
template <typename T>
vector<T> prefix_sum(vector<T> vec){
    for(int i=1;i<vec.size();i++){
        vec[i]+=vec[i-1];
    }
    return vec;
}
template <typename T>
vector<vector<T>> prefix_sum(vector<vector<T>> vec){
    for(int i=0;i<vec.size();i++){
        vec[i]=prefix_sum(vec[i]);
        if(i){
            rep(j,vec.size()){
                vec[i][j]+=vec[i-1][j];
            }
        }
    }
    return vec;
}

// 累積和から区間累積和を求める（閉区間）
// 引数は累積和配列、開始区間、終了区間
template <typename T>
T prefix_range_sum(const vector<T> &prefix_sum,const vector<ll> &begin,const vector<ll> &end,const int dep = 0){
    if(begin[dep]>end[dep])return 0;
    if(begin[dep]==0)return prefix_sum[end[dep]];
    return prefix_sum[end[dep]]-prefix_sum[begin[dep]-1];
}

template <typename T>
T prefix_range_sum(const vector<vector<T>> &prefix_sum,const vector<ll> &begin,const vector<ll> &end,const int dep = 0){
    if(begin[dep]>end[dep])return 0;
    if(begin[dep]==0)return prefix_range_sum(prefix_sum[end[dep]],begin,end,dep + 1);
    return prefix_range_sum(prefix_sum[end[dep]],begin,end,dep + 1) - prefix_range_sum(prefix_sum[begin[dep]-1],begin,end,dep + 1);
}

inline bool is_prime(ll n){
    if(n<2)return false;
    if(n==2)return true;
    if(n%2==0)return false;
    for(int i=3;i*i<=n;i+=2){
        if(n%i==0)return false;
    }
    return true;
}

#endif
