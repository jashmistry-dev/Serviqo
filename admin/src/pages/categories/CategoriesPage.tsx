import React, { useEffect, useState } from 'react';
import { FolderTree, MapPin, CheckCircle, RefreshCw, AlertCircle } from 'lucide-react';

interface Category {
  id: string;
  name: string;
  slug: string;
  description?: string;
  min_visiting_charge: string | number;
  is_active: boolean;
  sort_order: number;
}

interface City {
  id: string;
  name: string;
  state: string;
  pincode: string;
  is_active: boolean;
}

export const CategoriesPage: React.FC = () => {
  const [categories, setCategories] = useState<Category[]>([]);
  const [cities, setCities] = useState<City[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchData = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const [catRes, cityRes] = await Promise.all([
        fetch('http://127.0.0.1:8080/api/categories').then((r) => r.json()),
        fetch('http://127.0.0.1:8080/api/cities').then((r) => r.json()),
      ]);

      if (catRes.success && catRes.data?.categories) {
        setCategories(catRes.data.categories);
      }
      if (cityRes.success && cityRes.data?.cities) {
        setCities(cityRes.data.cities);
      }
    } catch (err: any) {
      setError('Could not connect to the backend server to load categories & cities.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div className="space-y-8 max-w-7xl">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white tracking-tight">Service Categories & Cities</h1>
          <p className="text-slate-400 text-sm mt-1">
            Browse service taxonomy, base visiting charges, and operating geographic boundaries.
          </p>
        </div>
        <div className="flex items-center space-x-3">
          <button
            onClick={fetchData}
            className="flex items-center space-x-2 px-3.5 py-2 bg-slate-900 border border-slate-800 hover:border-slate-700 text-slate-300 rounded-xl text-xs font-semibold transition-colors cursor-pointer"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isLoading ? 'animate-spin' : ''}`} />
            <span>Refresh</span>
          </button>
        </div>
      </div>

      {error && (
        <div className="p-4 bg-rose-500/10 border border-rose-500/20 rounded-xl flex items-center space-x-3 text-rose-300 text-xs">
          <AlertCircle className="w-4 h-4 flex-shrink-0 text-rose-400" />
          <span>{error}</span>
        </div>
      )}

      {/* Two column grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Categories List (2 cols) */}
        <div className="lg:col-span-2 space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <FolderTree className="w-5 h-5 text-indigo-400" />
              <h2 className="text-base font-bold text-white">Active Service Categories</h2>
              <span className="text-xs font-mono bg-indigo-500/20 text-indigo-300 px-2 py-0.5 rounded-full border border-indigo-500/30">
                {categories.length}
              </span>
            </div>
          </div>

          <div className="bg-slate-900/80 border border-slate-800/80 rounded-2xl overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-950/60 text-slate-400 uppercase tracking-wider font-semibold border-b border-slate-800">
                  <tr>
                    <th className="py-3.5 px-4">Category Name</th>
                    <th className="py-3.5 px-4">Slug</th>
                    <th className="py-3.5 px-4">Visiting Charge</th>
                    <th className="py-3.5 px-4">Status</th>
                    <th className="py-3.5 px-4 text-right">Order</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-800/60">
                  {categories.map((cat) => (
                    <tr key={cat.id} className="hover:bg-slate-800/30 transition-colors">
                      <td className="py-3 px-4">
                        <div className="font-semibold text-white">{cat.name}</div>
                        <div className="text-[11px] text-slate-400 truncate max-w-xs">{cat.description}</div>
                      </td>
                      <td className="py-3 px-4 font-mono text-indigo-300">{cat.slug}</td>
                      <td className="py-3 px-4 font-semibold text-emerald-400">
                        ₹{Number(cat.min_visiting_charge).toFixed(2)}
                      </td>
                      <td className="py-3 px-4">
                        <span className="inline-flex items-center space-x-1 text-[11px] font-semibold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded-full border border-emerald-500/20">
                          <CheckCircle className="w-3 h-3" />
                          <span>Active</span>
                        </span>
                      </td>
                      <td className="py-3 px-4 text-right font-mono text-slate-400">{cat.sort_order}</td>
                    </tr>
                  ))}
                  {categories.length === 0 && !isLoading && (
                    <tr>
                      <td colSpan={5} className="py-8 text-center text-slate-500">
                        No categories found in the database.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Operating Cities (1 col) */}
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <MapPin className="w-5 h-5 text-emerald-400" />
              <h2 className="text-base font-bold text-white">Operating Cities</h2>
              <span className="text-xs font-mono bg-emerald-500/20 text-emerald-300 px-2 py-0.5 rounded-full border border-emerald-500/30">
                {cities.length}
              </span>
            </div>
          </div>

          <div className="space-y-3">
            {cities.map((city) => (
              <div
                key={city.id}
                className="p-4 bg-slate-900/80 border border-slate-800/80 rounded-xl flex items-center justify-between hover:border-slate-700 transition-colors"
              >
                <div>
                  <div className="font-semibold text-white text-sm">{city.name}</div>
                  <div className="text-xs text-slate-400">State: {city.state}</div>
                </div>
                <div className="text-right">
                  <div className="text-xs font-mono text-indigo-300">PIN: {city.pincode}</div>
                  <span className="text-[10px] text-emerald-400 font-semibold uppercase">Covered Area</span>
                </div>
              </div>
            ))}
            {cities.length === 0 && !isLoading && (
              <div className="p-8 bg-slate-900/40 border border-slate-800 rounded-xl text-center text-slate-500 text-xs">
                No operating cities seeded.
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
