"use client";

import { App, ConfigProvider, theme, type ThemeConfig } from "antd";

const customerTheme: ThemeConfig = {
  algorithm: theme.defaultAlgorithm,
  token: {
    colorPrimary: "#0f766e",
    colorInfo: "#2563eb",
    colorSuccess: "#15803d",
    colorWarning: "#b45309",
    colorError: "#b42318",
    colorText: "#1f2523",
    colorTextSecondary: "#626b66",
    colorBgBase: "#f7f7f4",
    colorBgContainer: "#ffffff",
    colorBorder: "#d9ded8",
    borderRadius: 6,
    fontFamily: "Arial, Helvetica, sans-serif",
    wireframe: false
  },
  components: {
    Button: {
      controlHeight: 40,
      borderRadius: 6,
      fontWeight: 700
    },
    Card: {
      borderRadiusLG: 8
    },
    Input: {
      controlHeight: 40,
      borderRadius: 6
    },
    Select: {
      controlHeight: 40,
      borderRadius: 6
    },
    Table: {
      headerBg: "#f1f5f2",
      headerColor: "#1f2523"
    }
  }
};

export function Providers({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <ConfigProvider theme={customerTheme}>
      <App>{children}</App>
    </ConfigProvider>
  );
}
