import React from 'react';
import { useAuth } from '../../context/AuthContext';
import {
  Users,
  ShieldAlert,
  ClipboardList,
  CheckCircle,
  Database,
  Lock,
  Layers,
  ArrowUpRight,
  Sparkles,
} from 'lucide-react';

export const DashboardPage: React.FC = () => {
  const { user } = useAuth();

  const statCards = [
    {
      title: 'Technician Verifications',
      value: '1 Pending',
      sub: 'Phase 5 Review Queue',
      icon: ShieldAlert,
      color: 'amber',
    },
    {
      title: 'Registered Users',
      value: '4 Accounts',
      sub: 'Admin, Tech, Customer, Suspended',
      icon: Users,
      color: 'indigo',
    },
    {
      title: 'Active Categories',
      value: '6 Categories',
      sub: 'AC, Plumbing, Electrical, etc.',
      icon: Layers,
      color: 'emerald',
    },
    {
      title: 'Service Requests',
      value: '0 Active',
      sub: 'Phase 7 Request Queue',
      icon: ClipboardList,
      color: 'blue',
    },
  ];

  return (
    <div className="space-y-8 max-w-7xl">
      {/* Welcome Banner */}
      <div className="relative overflow-hidden bg-gradient-to-r from-indigo-900/60 via-slate-900 to-slate-900 border border-indigo-500/20 rounded-2xl p-6 md:p-8 backdrop-blur-xl">
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 relative z-10">
          <div>
            <div className="inline-flex items-center space-x-2 text-indigo-400 text-xs font-semibold uppercase tracking-wider mb-2">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Serviqo Super Admin Console</span>
            </div>
            <h1 className="text-2xl md:text-3xl font-bold text-white tracking-tight">
              Welcome back, {user?.name || 'Administrator'}
            </h1>
            <p className="text-slate-400 text-sm mt-1">
              Active authenticated session with Laravel Sanctum 4.3 & PostgreSQL 16 database.
            </p>
          </div>
          <div className="flex items-center space-x-3">
            <div className="px-3.5 py-2 bg-slate-800/80 border border-slate-700/80 rounded-xl text-xs">
              <span className="text-slate-400">Admin Email:</span>{' '}
              <span className="font-semibold text-slate-200">{user?.email}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Overview Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((stat, i) => {
          const Icon = stat.icon;
          return (
            <div
              key={i}
              className="bg-slate-900/80 border border-slate-800/80 rounded-xl p-5 hover:border-slate-700 transition-colors"
            >
              <div className="flex items-center justify-between mb-3">
                <span className="text-xs font-medium text-slate-400">{stat.title}</span>
                <div className="p-2 rounded-lg bg-slate-800 text-slate-300">
                  <Icon className="w-4 h-4" />
                </div>
              </div>
              <div className="text-xl font-bold text-white mb-1">{stat.value}</div>
              <div className="text-[11px] text-slate-500 flex items-center justify-between">
                <span>{stat.sub}</span>
                <ArrowUpRight className="w-3 h-3 text-slate-600" />
              </div>
            </div>
          );
        })}
      </div>

      {/* System Architecture & Security Status */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Architecture Status */}
        <div className="bg-slate-900/80 border border-slate-800/80 rounded-2xl p-6">
          <div className="flex items-center space-x-2.5 mb-4">
            <Database className="w-5 h-5 text-indigo-400" />
            <h3 className="font-semibold text-base text-white">Database & Infrastructure</h3>
          </div>
          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">PostgreSQL 16 Engine</span>
              <span className="text-emerald-400 flex items-center space-x-1.5 font-semibold">
                <CheckCircle className="w-3.5 h-3.5" />
                <span>Connected & Healthy</span>
              </span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Domain Tables & Migrations</span>
              <span className="text-slate-300 font-mono">23 Migrations (100% Applied)</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Primary Keys Strategy</span>
              <span className="text-slate-300 font-mono">UUID v4 (Strict)</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Monetary Fields Storage</span>
              <span className="text-slate-300 font-mono">DECIMAL(12,2)</span>
            </div>
          </div>
        </div>

        {/* Security & Role Enforcement */}
        <div className="bg-slate-900/80 border border-slate-800/80 rounded-2xl p-6">
          <div className="flex items-center space-x-2.5 mb-4">
            <Lock className="w-5 h-5 text-emerald-400" />
            <h3 className="font-semibold text-base text-white">Security & Access Control</h3>
          </div>
          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Token Driver</span>
              <span className="text-emerald-400 font-semibold">Laravel Sanctum 4.3</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Role Middleware</span>
              <span className="text-slate-300 font-mono">CheckRole (Active)</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Account Status Protection</span>
              <span className="text-slate-300">Blocks Inactive & Suspended</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-slate-950/60 rounded-xl border border-slate-800/60">
              <span className="text-slate-300 font-medium">Admin Authorization</span>
              <span className="text-indigo-400 font-semibold">Super Admin Privileges</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
