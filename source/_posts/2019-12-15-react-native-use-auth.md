---
layout: post
title: "基于React Hooks与Parse实现用户鉴权的最佳实践(useAuth)"
date: 2019-12-15 19:00:00 +0800
category: 技术
tags: [React Native, Hooks, useAuth, Parse]
---

用户鉴权是几乎所有app必备的功能与流程，不管是自己开发app server，还是使用[Parse](https://parseplatform.org/)等SaaS服务，都需要处理用户登录、注册、密码找回等一系列操作。而如何在客户端优雅地实现用户鉴权对每个开发者都是挑战。

最近在用React Native开发一个新app，服务端采用自建Parse服务，本文记录如何使用React Hooks来处理整个用户鉴权流程，自认为应该是best practice了:)

所有React app最常见也是最难处理的场景就是如何把状态从父节点传递到子节点，一个常见的解决方案是Redux，但总觉得在React Native上使用Redux有点重，而React 16.8以后提供的Hooks API无疑成了更好的选择。

废话不多说，直接上代码：

先看核心的Hook代码use-auth.js，这里封装了Parse登录注册等一系列方法，如果你是自建Server或其它服务，直接替换相关代码即可：
```javascript
// Hook (use-auth.js)
import React, { useState, useEffect, useContext, createContext } from 'react';
import Parse from 'parse/react-native';
import AsyncStorage from '@react-native-community/async-storage';

const setupParse = () => {
  Parse.initialize('your-app-id');
  Parse.serverURL = 'https://your-server-url/parse';
  Parse.setAsyncStorage(AsyncStorage);
};
setupParse();

const authContext = createContext();

// Provider component that wraps your app and makes auth object ...
// ... available to any child component that calls useAuth().
export function ProvideAuth({ children }) {
  const auth = useProvideAuth();
  return <authContext.Provider value={auth}>{children}</authContext.Provider>;
}

// Hook for child components to get the auth object ...
// ... and re-render when it changes.
export const useAuth = () => {
  return useContext(authContext);
};

// Provider hook that creates auth object and handles state
function useProvideAuth() {
  const [user, setUser] = useState(null);

  // Wrap any Parse methods we want to use making sure ...
  // ... to save the user to state.
  const signin = (username, password) => {
    return Parse.User
      .logIn(username, password)
      .then(currentUser => {
        setUser(currentUser);
        return currentUser;
      });
  };

  const signup = (username, email, password) => {
    return Parse.User
      .signUp(username, password, { email })
      .then(newUser => {
        setUser(newUser);
        return newUser;
      });
  };

  const signout = () => {
    return Parse.User
      .logOut()
      .then(() => setUser(false));
  };

  const sendPasswordResetEmail = email => {
    return Parse.User
      .requestPasswordReset(email)
      .then(() => {
        return true;
      });
  };

  const confirmPasswordReset = (code, password) => {
    return Parse.User
      .confirmPasswordReset(code, password)
      .then(() => {
        return true;
      });
  };

  // Subscribe to user on mount
  // Because this sets state in the callback it will cause any ...
  // ... component that utilizes this hook to re-render with the ...
  // ... latest auth object.
  useEffect(() => {
    Parse.User
      .currentAsync()
      .then(currentUser => {
        if (currentUser) {
          setUser(currentUser);
        } else {
          setUser(false);
        }
      });

    // Cleanup subscription on unmount
    // return () => unsubscribe();
  }, []);

  // Return the user object and auth methods
  return {
    user,
    signin,
    signup,
    signout,
    sendPasswordResetEmail,
    confirmPasswordReset,
  };
}
```

然后就可以在App.js中使用了，把根节点用`ProvideAuth`包一下就可以了：
```javascript
// Top level App component
import React from "react";
import { ProvideAuth } from "./use-auth.js";

const App = () => (
    <ProvideAuth>
      <AppNavigator />
    </ProvideAuth>
);

export default App;
```

这样，在任意需要用到用户鉴权相关的component就可以直接useAuth了，示例如下：
```javascript
// Any component that wants auth state
import React from "react";
import { useAuth } from "./use-auth.js";

function Navbar(props) {
  // Get auth state and re-render anytime it changes
  const auth = useAuth();

  return (
    <NavbarContainer>
      <Logo />
      <Menu>
        {auth.user ? (
          <Fragment>
            <Link to="/account">Account ({auth.user.email})</Link>
            <Button onClick={() => auth.signout()}>Signout</Button>
          </Fragment>
        ) : (
          <Link to="/signin">Signin</Link>
        )}
      </Menu>
    </NavbarContainer>
  );
}
```