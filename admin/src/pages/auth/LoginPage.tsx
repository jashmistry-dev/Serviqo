import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { ShieldCheck, Lock, Mail, AlertCircle, ArrowRight, Server, KeyRound } from 'lucide-react';

export const LoginPage: React.FC = () => {
  const { login, error, clearError } = useAuth();
  const [loginInput, setLoginInput] = useState('');
  const [password, setPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [localError, setLocalError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();
    setLocalError(null);

    if (!loginInput.trim()) {
      setLocalError('Please enter your email or registered phone number.');
      return;
    }
    if (!password) {
      setLocalError('Please enter your administrator password.');
      return;
    }

    setIsSubmitting(true);
    try {
      await login(loginInput.trim(), password);
    } catch (err: any) {
      // Error is stored in AuthContext and rendered
    } finally {
      setIsSubmitting(false);
    }
  };

  const fillDemoAdmin = () => {
    setLoginInput('admin@serviqo.com');
    setPassword('Admin@123');
    clearError();
    setLocalError(null);
  };

  const activeError = localError || error;

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col justify-center items-center p-4 relative overflow-hidden">
      {/* Background ambient glow */}
      <div className="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-indigo-600/10 rounded-full blur-3xl pointer-events-none" />
      <div className="absolute bottom-10 right-10 w-80 h-80 bg-blue-600/10 rounded-full blur-3xl pointer-events-none" />

      {/* Main card */}
      <div className="w-full max-w-md bg-slate-900/90 border border-slate-800 rounded-2xl shadow-2xl p-8 backdrop-blur-xl relative z-10">
        {/* Header */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-14 h-14 rounded-xl bg-indigo-600/20 border border-indigo-500/30 text-indigo-400 mb-4 shadow-inner">
            <ShieldCheck className="w-7 h-7" />
          </div>
          <h1 className="text-2xl font-bold tracking-tight text-white">Serviqo Admin</h1>
          <p className="text-slate-400 text-sm mt-1">Super Administrator Control Console</p>
        </div>

        {/* Demo Credentials Chip */}
        <div className="mb-6 p-3 bg-slate-800/60 border border-slate-700/60 rounded-xl flex items-center justify-between">
          <div className="flex items-center space-x-2 text-xs text-slate-300">
            <KeyRound className="w-4 h-4 text-amber-400 flex-shrink-0" />
            <div>
              <p className="font-semibold text-slate-200">Demo Admin Credentials</p>
              <p className="text-slate-400">admin@serviqo.com / Admin@123</p>
            </div>
          </div>
          <button
            type="button"
            onClick={fillDemoAdmin}
            className="text-xs font-semibold px-2.5 py-1 bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 rounded-lg transition-colors cursor-pointer"
          >
            Auto-fill
          </button>
        </div>

        {/* Error Alert */}
        {activeError && (
          <div className="mb-6 p-3.5 bg-rose-500/10 border border-rose-500/30 rounded-xl flex items-start space-x-3 text-rose-300 text-sm">
            <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5 text-rose-400" />
            <div className="flex-1 text-xs leading-relaxed">{activeError}</div>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Email or Phone
            </label>
            <div className="relative">
              <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={loginInput}
                onChange={(e) => setLoginInput(e.target.value)}
                placeholder="admin@serviqo.com"
                className="w-full bg-slate-950/80 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-colors"
                disabled={isSubmitting}
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-1.5">
              Password
            </label>
            <div className="relative">
              <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full bg-slate-950/80 border border-slate-800 rounded-xl pl-10 pr-4 py-2.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-colors"
                disabled={isSubmitting}
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={isSubmitting}
            className="w-full mt-2 py-3 px-4 bg-indigo-600 hover:bg-indigo-500 disabled:bg-indigo-900/50 text-white text-sm font-semibold rounded-xl shadow-lg shadow-indigo-600/30 transition-all flex items-center justify-center space-x-2 cursor-pointer disabled:cursor-not-allowed"
          >
            {isSubmitting ? (
              <div className="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin" />
            ) : (
              <>
                <span>Sign In to Super Admin</span>
                <ArrowRight className="w-4 h-4" />
              </>
            )}
          </button>
        </form>

        {/* Security Footer Notice */}
        <div className="mt-8 pt-6 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-500">
          <div className="flex items-center space-x-1.5">
            <Server className="w-3.5 h-3.5 text-emerald-400" />
            <span>PostgreSQL 16 · Sanctum 4.3</span>
          </div>
          <span>Strict RBAC Active</span>
        </div>
      </div>
    </div>
  );
};
