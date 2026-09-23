import React, { useEffect, useState } from 'react';
import {
  ShieldCheck,
  ShieldAlert,
  Search,
  Check,
  X,
  AlertTriangle,
  FileText,
  RefreshCw,
  ExternalLink,
  MapPin,
  Clock,
  AlertCircle,
} from 'lucide-react';
import { tokenStorage } from '../../api/client';

interface VerificationDoc {
  id: string;
  document_type: string;
  document_number?: string | null;
  file_path: string;
  status: string;
  rejection_reason?: string | null;
  created_at: string;
}

interface TechnicianItem {
  id: string;
  experience_years: number;
  visiting_charge: string | number;
  verification_status: 'pending' | 'under_review' | 'verified' | 'rejected' | 'suspended';
  verification_notes?: string | null;
  is_available: boolean;
  verifications_count: number;
  user: {
    id: string;
    name: string;
    email: string;
    phone: string;
    status: string;
  };
  city?: {
    name: string;
    state: string;
  } | null;
  verifications?: VerificationDoc[];
}

export const VerificationsPage: React.FC = () => {
  const [technicians, setTechnicians] = useState<TechnicianItem[]>([]);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // Selected tech for review modal
  const [selectedTech, setSelectedTech] = useState<TechnicianItem | null>(null);
  const [reviewReason, setReviewReason] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState<boolean>(false);
  const [actionError, setActionError] = useState<string | null>(null);

  const fetchQueue = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const token = tokenStorage.get();
      const params = new URLSearchParams();
      if (filterStatus !== 'all') params.append('status', filterStatus);
      if (searchQuery.trim()) params.append('search', searchQuery.trim());

      const res = await fetch(`http://127.0.0.1:8080/api/admin/verifications?${params.toString()}`, {
        headers: {
          Authorization: `Bearer ${token}`,
          Accept: 'application/json',
        },
      });

      const data = await res.json();
      if (data.success && data.data?.technicians?.data) {
        setTechnicians(data.data.technicians.data);
      } else {
        setTechnicians([]);
      }
    } catch (err: any) {
      setError('Failed to connect to backend verification queue.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchQueue();
  }, [filterStatus]);

  const handleReviewAction = async (action: 'approve' | 'reject' | 'suspend') => {
    if (!selectedTech) return;
    setActionError(null);

    if ((action === 'reject' || action === 'suspend') && !reviewReason.trim()) {
      setActionError(`A specific reason is mandatory when performing ${action}.`);
      return;
    }

    setIsProcessing(true);
    try {
      const token = tokenStorage.get();
      const res = await fetch(`http://127.0.0.1:8080/api/admin/verifications/${selectedTech.id}/review`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
          Accept: 'application/json',
        },
        body: JSON.stringify({
          action,
          reason: reviewReason.trim() || undefined,
        }),
      });

      const data = await res.json();
      if (!res.ok || !data.success) {
        setActionError(data.message || 'Action failed');
        return;
      }

      // Close modal and refresh list
      setSelectedTech(null);
      setReviewReason('');
      fetchQueue();
    } catch (err: any) {
      setActionError(err.message || 'Network request failed');
    } finally {
      setIsProcessing(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'verified':
        return (
          <span className="inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
            <Check className="w-3 h-3" />
            <span>Verified</span>
          </span>
        );
      case 'under_review':
        return (
          <span className="inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
            <Clock className="w-3 h-3" />
            <span>Under Review</span>
          </span>
        );
      case 'pending':
        return (
          <span className="inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">
            <FileText className="w-3 h-3" />
            <span>Pending Submission</span>
          </span>
        );
      case 'rejected':
        return (
          <span className="inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-rose-500/10 text-rose-400 border border-rose-500/20">
            <X className="w-3 h-3" />
            <span>Rejected</span>
          </span>
        );
      case 'suspended':
        return (
          <span className="inline-flex items-center space-x-1 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-red-950 text-red-400 border border-red-800">
            <AlertTriangle className="w-3 h-3" />
            <span>Suspended</span>
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="space-y-8 max-w-7xl">
      {/* Header & Disclaimer */}
      <div>
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center space-x-2">
              <ShieldCheck className="w-6 h-6 text-indigo-400" />
              <h1 className="text-2xl font-bold text-white tracking-tight">Technician Verifications</h1>
            </div>
            <p className="text-slate-400 text-sm mt-1">
              Review government credentials, license records, and approve or reject marketplace technicians.
            </p>
          </div>
          <button
            onClick={fetchQueue}
            className="flex items-center space-x-2 px-3.5 py-2 bg-slate-900 border border-slate-800 hover:border-slate-700 text-slate-300 rounded-xl text-xs font-semibold transition-colors cursor-pointer"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh Queue</span>
          </button>
        </div>

        {/* Mandatory Policy Disclaimer */}
        <div className="mt-4 p-3 bg-indigo-500/10 border border-indigo-500/20 rounded-xl flex items-center space-x-3 text-xs text-indigo-300">
          <ShieldAlert className="w-4 h-4 flex-shrink-0 text-indigo-400" />
          <span>
            Compliance Policy: Serviqo grants "Verified" status based solely on submitted and reviewed information.
            Guarantees of "100% genuine" are strictly prohibited by platform guidelines.
          </span>
        </div>
      </div>

      {/* Filters & Search */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-slate-900/60 border border-slate-800 p-3.5 rounded-2xl">
        {/* Status Tab Pills */}
        <div className="flex items-center space-x-1 overflow-x-auto pb-1 sm:pb-0">
          {[
            { id: 'all', label: 'All Technicians' },
            { id: 'under_review', label: 'Under Review' },
            { id: 'pending', label: 'Pending Docs' },
            { id: 'verified', label: 'Verified' },
            { id: 'rejected', label: 'Rejected' },
            { id: 'suspended', label: 'Suspended' },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setFilterStatus(tab.id)}
              className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors cursor-pointer whitespace-nowrap ${
                filterStatus === tab.id
                  ? 'bg-indigo-600 text-white font-semibold shadow-sm'
                  : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/60'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Search Input */}
        <div className="relative">
          <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by name, email, phone..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && fetchQueue()}
            className="w-full sm:w-64 bg-slate-950 border border-slate-800 rounded-xl pl-9 pr-4 py-1.5 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500"
          />
        </div>
      </div>

      {error && (
        <div className="p-4 bg-rose-500/10 border border-rose-500/20 rounded-xl flex items-center space-x-3 text-rose-300 text-xs">
          <AlertCircle className="w-4 h-4 flex-shrink-0 text-rose-400" />
          <span>{error}</span>
        </div>
      )}

      {/* Technicians Table */}
      <div className="bg-slate-900/80 border border-slate-800/80 rounded-2xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs">
            <thead className="bg-slate-950/60 text-slate-400 uppercase tracking-wider font-semibold border-b border-slate-800">
              <tr>
                <th className="py-3.5 px-4">Technician Details</th>
                <th className="py-3.5 px-4">Operating City</th>
                <th className="py-3.5 px-4">Experience</th>
                <th className="py-3.5 px-4">Visiting Charge</th>
                <th className="py-3.5 px-4">Documents</th>
                <th className="py-3.5 px-4">Verification Status</th>
                <th className="py-3.5 px-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800/60">
              {technicians.map((tech) => (
                <tr key={tech.id} className="hover:bg-slate-800/30 transition-colors">
                  <td className="py-3 px-4">
                    <div className="font-semibold text-white text-sm">{tech.user.name}</div>
                    <div className="text-[11px] text-slate-400">{tech.user.email}</div>
                    <div className="text-[11px] font-mono text-slate-500">{tech.user.phone}</div>
                  </td>
                  <td className="py-3 px-4 text-slate-300">
                    <div className="flex items-center space-x-1">
                      <MapPin className="w-3.5 h-3.5 text-slate-400" />
                      <span>{tech.city ? `${tech.city.name}` : 'Not Set'}</span>
                    </div>
                  </td>
                  <td className="py-3 px-4 font-semibold text-white">{tech.experience_years} years</td>
                  <td className="py-3 px-4 font-semibold text-emerald-400">
                    ₹{Number(tech.visiting_charge).toFixed(2)}
                  </td>
                  <td className="py-3 px-4">
                    <span className="font-mono bg-slate-800 text-slate-300 px-2 py-0.5 rounded text-[11px]">
                      {tech.verifications_count} uploaded
                    </span>
                  </td>
                  <td className="py-3 px-4">{getStatusBadge(tech.verification_status)}</td>
                  <td className="py-3 px-4 text-right">
                    <button
                      onClick={() => {
                        setSelectedTech(tech);
                        setReviewReason(tech.verification_notes || '');
                        setActionError(null);
                      }}
                      className="px-3 py-1.5 bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 rounded-lg font-semibold transition-colors cursor-pointer"
                    >
                      Review Dossier
                    </button>
                  </td>
                </tr>
              ))}
              {technicians.length === 0 && !isLoading && (
                <tr>
                  <td colSpan={7} className="py-12 text-center text-slate-500">
                    No technicians found matching filter criteria.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Review Modal */}
      {selectedTech && (
        <div className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="w-full max-w-2xl bg-slate-900 border border-slate-800 rounded-2xl shadow-2xl p-6 space-y-6">
            <div className="flex items-start justify-between border-b border-slate-800 pb-4">
              <div>
                <h3 className="text-lg font-bold text-white">Technician Dossier Review</h3>
                <p className="text-xs text-slate-400 mt-0.5">
                  Candidate: <span className="text-white font-semibold">{selectedTech.user.name}</span> (
                  {selectedTech.user.email})
                </p>
              </div>
              <button
                onClick={() => setSelectedTech(null)}
                className="p-1 text-slate-400 hover:text-white rounded-lg"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {actionError && (
              <div className="p-3 bg-rose-500/10 border border-rose-500/20 rounded-xl flex items-center space-x-2 text-xs text-rose-300">
                <AlertCircle className="w-4 h-4 flex-shrink-0 text-rose-400" />
                <span>{actionError}</span>
              </div>
            )}

            {/* Profile Overview */}
            <div className="grid grid-cols-3 gap-3 p-3 bg-slate-950 rounded-xl text-xs">
              <div>
                <span className="text-slate-500">City / Location</span>
                <p className="font-semibold text-white">{selectedTech.city?.name || 'Pan-India'}</p>
              </div>
              <div>
                <span className="text-slate-500">Experience</span>
                <p className="font-semibold text-white">{selectedTech.experience_years} Years</p>
              </div>
              <div>
                <span className="text-slate-500">Visiting Fee</span>
                <p className="font-semibold text-emerald-400">₹{Number(selectedTech.visiting_charge).toFixed(2)}</p>
              </div>
            </div>

            {/* Documents List */}
            <div className="space-y-2">
              <h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider">
                Submitted Verification Documents ({selectedTech.verifications?.length || 0})
              </h4>
              {selectedTech.verifications && selectedTech.verifications.length > 0 ? (
                <div className="space-y-2 max-h-48 overflow-y-auto pr-1">
                  {selectedTech.verifications.map((doc) => (
                    <div
                      key={doc.id}
                      className="p-3 bg-slate-950/60 border border-slate-800 rounded-xl flex items-center justify-between text-xs"
                    >
                      <div className="flex items-center space-x-3">
                        <FileText className="w-4 h-4 text-indigo-400" />
                        <div>
                          <p className="font-semibold text-white capitalize">{doc.document_type.replace('_', ' ')}</p>
                          <p className="text-[11px] text-slate-400 font-mono">No: {doc.document_number || 'N/A'}</p>
                        </div>
                      </div>
                      <a
                        href={`http://127.0.0.1:8080/storage/${doc.file_path}`}
                        target="_blank"
                        rel="noreferrer"
                        className="flex items-center space-x-1 px-2.5 py-1 bg-slate-800 hover:bg-slate-700 text-indigo-300 rounded-lg text-[11px]"
                      >
                        <span>View Document</span>
                        <ExternalLink className="w-3 h-3" />
                      </a>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="p-4 bg-slate-950 rounded-xl text-center text-slate-500 text-xs">
                  No documents uploaded yet by this technician.
                </div>
              )}
            </div>

            {/* Reason / Notes Input */}
            <div>
              <label className="block text-xs font-semibold text-slate-400 uppercase tracking-wider mb-1.5">
                Review Decision Notes / Reason (Required for Reject & Suspend)
              </label>
              <textarea
                value={reviewReason}
                onChange={(e) => setReviewReason(e.target.value)}
                placeholder="Enter justification, missing documents, or audit observations..."
                rows={2}
                className="w-full bg-slate-950 border border-slate-800 rounded-xl p-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-indigo-500"
              />
            </div>

            {/* Action Buttons */}
            <div className="flex items-center justify-end space-x-3 pt-4 border-t border-slate-800">
              <button
                type="button"
                onClick={() => setSelectedTech(null)}
                disabled={isProcessing}
                className="px-4 py-2 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-xl text-xs font-semibold transition-colors cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={() => handleReviewAction('reject')}
                disabled={isProcessing}
                className="px-4 py-2 bg-rose-600/20 hover:bg-rose-600/30 text-rose-300 border border-rose-500/30 rounded-xl text-xs font-semibold transition-colors cursor-pointer"
              >
                Reject Application
              </button>
              <button
                type="button"
                onClick={() => handleReviewAction('suspend')}
                disabled={isProcessing}
                className="px-4 py-2 bg-amber-600/20 hover:bg-amber-600/30 text-amber-300 border border-amber-500/30 rounded-xl text-xs font-semibold transition-colors cursor-pointer"
              >
                Suspend Account
              </button>
              <button
                type="button"
                onClick={() => handleReviewAction('approve')}
                disabled={isProcessing}
                className="px-4 py-2 bg-emerald-600 hover:bg-emerald-500 text-white rounded-xl text-xs font-semibold shadow-md shadow-emerald-600/20 transition-colors cursor-pointer"
              >
                {isProcessing ? 'Processing...' : 'Approve & Verify'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
