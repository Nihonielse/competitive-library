// Library and Editor Setting is here: https://github.com/Nihonielse/competitive-library

#ifndef CORE_FILE
#define CORE_FILE

#include <bits/stdc++.h>
using namespace std;

using ll = long long;
using ull = unsigned long long;

#define rep(i, n) for (int i = 0; i < n; i++)
#define rrep(i, n, s) for (int i = s; i < n; i++)

#define vall(v) v.begin(), v.end()

constexpr int INF = 1 << 30;
constexpr int NEG_INF = -INF;
constexpr ll LINF = 1ll << 62;
constexpr ll NEG_LINF = -LINF;

template <typename T> inline bool chmax(T &a, const T &b) {
  if (a < b) {
    a = b;
    return true;
  }
  return false;
}

template <typename T> inline bool chmin(T &a, const T &b) {
  if (a > b) {
    a = b;
    return true;
  }
  return false;
}

#endif
