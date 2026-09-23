import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import {
  LayoutDashboard,
  ShieldCheck,
  Users,
  Wrench,
  FolderTree,
  FileText,
  DollarSign,
  AlertTriangle,
  ScrollText,
  Settings,
  LogOut,
  Menu,
  X,
  Server,
  Activity,
  CheckCircle2,
} from 'lucide-react';

interface AdminShellProps {
  children: React.ReactNode;
  activeTab?: string;
  onTabChange?: (tab: string) => void;
}

export const AdminShell: React.FC<AdminShellProps> = ({
  children,
  activeTab = 'dashboard',
  onTabChange,
}) => {
  const { user, logout } = useAuth();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const navItems = [
    { id: 'dashboard', label: 'Overview', icon: LayoutDashboard },
    { id: 'verifications', label: 'Technician Verifications', icon: ShieldCheck, badge: 'Phase 5' },
    { id: 'categories', label: 'Categories & Cities', icon: FolderTree, badge: 'Phase 4' },
    { id: 'requests', label: 'Service Requests', icon: Wrench, badge: 'Phase 7' },
    { id: 'quotations', label: 'Quotations', icon: FileText, badge: 'Phase 11' },
    { id: 'financials', label: 'Payments & Fees', icon: DollarSign, badge: 'Phase 13' },
    { id: 'disputes', label: 'Complaints & Disputes', icon: AlertTriangle, badge: 'Phase 16' },
    { id: 'audit', label: 'Audit Logs', icon: ScrollText, badge: 'Phase 20' },
    { id: 'users', label: 'User Directory', icon: Users },
    { id: 'settings', label: 'Platform Settings', icon: Settings },
  ];

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col md:flex-row font-sans">
      {/* Sidebar Desktop */}
      <aside className="hidden md:flex flex-col w-64 bg-slate-900/95 border-r border-slate-800/80 flex-shrink-0">
        {/* Brand */}
        <div className="h-16 px-6 flex items-center space-x-3 border-b border-slate-800/80">
          <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center text-white font-bold shadow-md shadow-indigo-600/30">
            S
          </div>
          <div>
            <span className="font-bold text-base tracking-tight text-white">Serviqo</span>
            <span className="text-[10px] ml-1.5 px-1.5 py-0.5 rounded bg-indigo-500/20 text-indigo-300 font-semibold border border-indigo-500/30 uppercase">
              Admin
            </span>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => onTabChange && onTabChange(item.id)}
                className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-medium transition-colors cursor-pointer ${
                  isActive
                    ? 'bg-indigo-600 text-white shadow-sm shadow-indigo-600/20'
                    : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
                }`}
              >
                <div className="flex items-center space-x-3">
                  <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-slate-400'}`} />
                  <span>{item.label}</span>
                </div>
                {item.badge && !isActive && (
                  <span className="text-[9px] px-1.5 py-0.5 rounded bg-slate-800 text-slate-400 font-mono">
                    {item.badge}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        {/* Database Health Pill */}
        <div className="p-3 m-3 bg-slate-950/60 border border-slate-800/80 rounded-xl text-xs space-y-1">
          <div className="flex items-center space-x-2 text-slate-300">
            <Server className="w-3.5 h-3.5 text-emerald-400" />
            <span className="font-semibold text-[11px]">Database Active</span>
          </div>
          <p className="text-[10px] text-slate-400">PostgreSQL 16 · Docker 5432</p>
        </div>

        {/* Admin Profile & Logout */}
        <div className="p-3 border-t border-slate-800/80 flex items-center justify-between">
          <div className="flex items-center space-x-2.5 min-w-0">
            <div className="w-8 h-8 rounded-full bg-slate-800 border border-slate-700 flex items-center justify-center font-bold text-xs text-indigo-400">
              {user?.name ? user.name[0].toUpperCase() : 'A'}
            </div>
            <div className="min-w-0">
              <p className="text-xs font-semibold text-white truncate">{user?.name || 'Administrator'}</p>
              <p className="text-[10px] text-emerald-400 font-medium">SUPER ADMIN</p>
            </div>
          </div>
          <button
            onClick={() => logout()}
            title="Sign out of Admin"
            className="p-1.5 text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 rounded-lg transition-colors cursor-pointer"
          >
            <LogOut className="w-4 h-4" />
          </button>
        </div>
      </aside>

      {/* Mobile Header */}
      <header className="md:hidden h-14 bg-slate-900 border-b border-slate-800 px-4 flex items-center justify-between sticky top-0 z-30">
        <div className="flex items-center space-x-2">
          <div className="w-7 h-7 rounded-lg bg-indigo-600 flex items-center justify-center text-white font-bold text-xs">
            S
          </div>
          <span className="font-bold text-sm text-white">Serviqo Admin</span>
        </div>
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="p-1.5 text-slate-300 hover:text-white"
        >
          {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>
      </header>

      {/* Mobile Drawer Menu */}
      {mobileMenuOpen && (
        <div className="md:hidden fixed inset-0 top-14 bg-slate-950/95 z-20 p-4 space-y-1 overflow-y-auto">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => {
                  onTabChange && onTabChange(item.id);
                  setMobileMenuOpen(false);
                }}
                className={`w-full flex items-center justify-between px-3.5 py-3 rounded-xl text-sm font-medium ${
                  isActive ? 'bg-indigo-600 text-white' : 'text-slate-300 hover:bg-slate-900'
                }`}
              >
                <div className="flex items-center space-x-3">
                  <Icon className="w-4 h-4" />
                  <span>{item.label}</span>
                </div>
                {item.badge && <span className="text-xs text-slate-400 font-mono">{item.badge}</span>}
              </button>
            );
          })}
          <div className="pt-4 border-t border-slate-800">
            <button
              onClick={() => logout()}
              className="w-full flex items-center space-x-3 px-3.5 py-3 text-sm text-rose-400 hover:bg-rose-500/10 rounded-xl"
            >
              <LogOut className="w-4 h-4" />
              <span>Sign Out ({user?.email})</span>
            </button>
          </div>
        </div>
      )}

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-y-auto">
        {/* Top Navbar */}
        <header className="hidden md:flex h-16 bg-slate-900/40 border-b border-slate-800/80 px-8 items-center justify-between backdrop-blur-sm">
          <div className="flex items-center space-x-3">
            <h2 className="text-sm font-semibold text-slate-200 capitalize">
              {navItems.find((i) => i.id === activeTab)?.label || 'Overview'}
            </h2>
            <span className="flex items-center space-x-1.5 text-[11px] text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full font-medium">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
              <span>API Live</span>
            </span>
          </div>

          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2 text-xs text-slate-400 bg-slate-900/80 border border-slate-800 px-3 py-1.5 rounded-lg">
              <Activity className="w-3.5 h-3.5 text-indigo-400" />
              <span>Sanctum v4.3 Session</span>
            </div>
            <div className="flex items-center space-x-2 text-xs text-slate-400 bg-slate-900/80 border border-slate-800 px-3 py-1.5 rounded-lg">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
              <span>Role: Super Admin</span>
            </div>
          </div>
        </header>

        {/* View container */}
        <main className="flex-1 p-6 md:p-8 bg-slate-950">{children}</main>
      </div>
    </div>
  );
};
