import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LoginPage } from './pages/auth/LoginPage';
import { AdminShell } from './components/layout/AdminShell';
import { DashboardPage } from './pages/dashboard/DashboardPage';
import { CategoriesPage } from './pages/categories/CategoriesPage';
import { VerificationsPage } from './pages/verifications/VerificationsPage';

const AdminApp: React.FC = () => {
  const { isAuthenticated, isLoading } = useAuth();
  const [activeTab, setActiveTab] = useState('dashboard');

  if (isLoading) {
    return (
      <div className="min-h-screen bg-slate-950 flex flex-col items-center justify-center space-y-4">
        <div className="w-10 h-10 border-3 border-indigo-500/20 border-t-indigo-500 rounded-full animate-spin" />
        <p className="text-slate-400 text-xs font-mono">Initializing Serviqo Admin Session...</p>
      </div>
    );
  }

  if (!isAuthenticated) {
    return <LoginPage />;
  }

  return (
    <AdminShell activeTab={activeTab} onTabChange={setActiveTab}>
      {activeTab === 'dashboard' && <DashboardPage />}
      {activeTab === 'verifications' && <VerificationsPage />}
      {activeTab === 'categories' && <CategoriesPage />}
      {activeTab !== 'dashboard' && activeTab !== 'verifications' && activeTab !== 'categories' && (
        <div className="p-8 bg-slate-900/60 border border-slate-800 rounded-2xl text-center">
          <p className="text-slate-400 text-sm">
            Module <span className="font-mono text-indigo-400 font-semibold">{activeTab}</span> will be populated in subsequent phases.
          </p>
        </div>
      )}
    </AdminShell>
  );
};

export default function App() {
  return (
    <AuthProvider>
      <AdminApp />
    </AuthProvider>
  );
}
