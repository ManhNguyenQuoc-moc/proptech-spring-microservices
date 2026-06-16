"use client";

import { App, ConfigProvider, theme, type ThemeConfig } from "antd";

const adminTheme: ThemeConfig = {
  algorithm: theme.defaultAlgorithm,
  token: {
    colorPrimary: "#334155",
    colorInfo: "#2563eb",
    colorSuccess: "#15803d",
    colorWarning: "#b45309",
    colorError: "#b42318",
    colorText: "#1e293b",
    colorTextSecondary: "#64748b",
    colorBgBase: "#f6f7f9",
    colorBgContainer: "#ffffff",
    colorBorder: "#d7dde5",
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
    Layout: {
      bodyBg: "#f6f7f9",
      headerBg: "#ffffff",
      siderBg: "#ffffff"
    },
    Menu: {
      itemBorderRadius: 6,
      itemSelectedBg: "#e2e8f0",
      itemSelectedColor: "#1e293b"
    },
    Select: {
      controlHeight: 40,
      borderRadius: 6
    },
    Table: {
      headerBg: "#eef2f7",
      headerColor: "#1e293b"
    }
  }
};

export function Providers({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <ConfigProvider theme={adminTheme}>
      <App>{children}</App>
    </ConfigProvider>
  );
}
