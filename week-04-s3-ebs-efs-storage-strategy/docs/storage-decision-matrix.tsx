import { useState } from "react";

const GRAY = "#6e6e73";
const DARK = "#1d1d1f";
const BLUE = "#0071e3";
const GREEN = "#1d7a4a";
const LIGHT = "#f5f5f7";
const RED = "#c5221f";

const services = ["S3 Standard", "S3-IA", "S3 Glacier\nDeep Archive", "EBS gp3", "EBS io2", "EFS", "FSx Lustre"];
const serviceKeys = ["S3 Standard", "S3-IA", "S3 Glacier Deep Archive", "EBS gp3", "EBS io2", "EFS", "FSx Lustre"];

const matrix = {
  "Type": {
    "S3 Standard": "Object", "S3-IA": "Object", "S3 Glacier Deep Archive": "Object",
    "EBS gp3": "Block", "EBS io2": "Block", "EFS": "File (NFS)", "FSx Lustre": "File (Lustre)",
  },
  "Access Pattern": {
    "S3 Standard": "HTTP API, any client", "S3-IA": "HTTP API, infrequent", "S3 Glacier Deep Archive": "Bulk retrieval, rare",
    "EBS gp3": "Single EC2 only", "EBS io2": "Single EC2 only", "EFS": "Multi-EC2 concurrent", "FSx Lustre": "Multi-EC2 (HPC)",
  },
  "Max Size": {
    "S3 Standard": "Unlimited", "S3-IA": "Unlimited", "S3 Glacier Deep Archive": "Unlimited",
    "EBS gp3": "16 TiB", "EBS io2": "64 TiB", "EFS": "Unlimited", "FSx Lustre": "Unlimited",
  },
  "Durability": {
    "S3 Standard": "99.999999999%", "S3-IA": "99.999999999%", "S3 Glacier Deep Archive": "99.999999999%",
    "EBS gp3": "99.8–99.9%", "EBS io2": "99.999%", "EFS": "99.999999999%", "FSx Lustre": "N/A (scratch)",
  },
  "Availability": {
    "S3 Standard": "99.99%", "S3-IA": "99.9%", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "99.999%", "EBS io2": "99.999%", "EFS": "99.99%", "FSx Lustre": "~99.9%",
  },
  "Cost / GB-mo": {
    "S3 Standard": "$0.023", "S3-IA": "$0.0125", "S3 Glacier Deep Archive": "$0.00099",
    "EBS gp3": "$0.08", "EBS io2": "$0.125", "EFS": "$0.30", "FSx Lustre": "$0.14",
  },
  "Cost / TB / Year": {
    "S3 Standard": "~$284", "S3-IA": "~$170", "S3 Glacier Deep Archive": "~$12",
    "EBS gp3": "~$984", "EBS io2": "~$1,536", "EFS": "~$3,686", "FSx Lustre": "~$1,720",
  },
  "Retrieval Fee": {
    "S3 Standard": "None", "S3-IA": "$0.01/GB", "S3 Glacier Deep Archive": "$0.02/GB (bulk)",
    "EBS gp3": "N/A", "EBS io2": "N/A", "EFS": "N/A", "FSx Lustre": "N/A",
  },
  "Max IOPS": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "16,000", "EBS io2": "256,000", "EFS": "~500K (elastic)", "FSx Lustre": "Millions",
  },
  "Max Throughput": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "1,000 MB/s", "EBS io2": "4,000 MB/s", "EFS": "~1 GB/s (elastic)", "FSx Lustre": "1+ TB/s",
  },
  "Seq Write (MB/s) ¹": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "139", "EBS io2": "—", "EFS": "109", "FSx Lustre": "—",
    "_winner": "EBS gp3",
  },
  "Seq Read (MB/s) ¹": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "136", "EBS io2": "—", "EFS": "302", "FSx Lustre": "—",
    "_winner": "EFS",
  },
  "Rand 4K Read IOPS ¹": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "7,017", "EBS io2": "—", "EFS": "4,704", "FSx Lustre": "—",
    "_winner": "EBS gp3",
  },
  "Rand 4K Write IOPS ¹": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "7,076", "EBS io2": "—", "EFS": "4,727", "FSx Lustre": "—",
    "_winner": "EBS gp3",
  },
  "Avg Latency (usec) ¹": {
    "S3 Standard": "N/A", "S3-IA": "N/A", "S3 Glacier Deep Archive": "N/A",
    "EBS gp3": "677", "EBS io2": "—", "EFS": "3,472", "FSx Lustre": "—",
    "_winner": "EBS gp3",
  },
  "Multi-Instance": {
    "S3 Standard": "✅ Yes", "S3-IA": "✅ Yes", "S3 Glacier Deep Archive": "✅ Yes",
    "EBS gp3": "❌ No", "EBS io2": "⚠️ Limited", "EFS": "✅ Yes", "FSx Lustre": "✅ Yes",
  },
  "POSIX Filesystem": {
    "S3 Standard": "❌ No", "S3-IA": "❌ No", "S3 Glacier Deep Archive": "❌ No",
    "EBS gp3": "✅ Yes", "EBS io2": "✅ Yes", "EFS": "✅ Yes", "FSx Lustre": "✅ Yes",
  },
  "Use When": {
    "S3 Standard": "Static assets, active data lakes, frequent access",
    "S3-IA": "Backups, DR copies, data accessed <1×/month",
    "S3 Glacier Deep Archive": "Compliance archives, data accessed <1×/year",
    "EBS gp3": "Boot volumes, databases, default block storage",
    "EBS io2": "High-IOPS databases (Oracle, SQL Server, SAP HANA)",
    "EFS": "Shared config, CMS media, ASG web servers",
    "FSx Lustre": "ML training, HPC, genomics, video processing",
  },
  "Don't Use When": {
    "S3 Standard": "Need filesystem mount or low-latency block ops",
    "S3-IA": "Data accessed frequently — retrieval fees negate savings",
    "S3 Glacier Deep Archive": "Need data in under 12 hours",
    "EBS gp3": "Need shared access across multiple EC2 instances",
    "EBS io2": "Cost-sensitive; gp3 handles most workloads",
    "EFS": "Need raw, consistent IOPS; single-instance workloads",
    "FSx Lustre": "Standard web apps; overkill unless HPC",
  },
};

const benchmarkRows = ["Seq Write (MB/s) ¹", "Seq Read (MB/s) ¹", "Rand 4K Read IOPS ¹", "Rand 4K Write IOPS ¹", "Avg Latency (usec) ¹"];

const sectionGroups = [
  { label: "Overview", rows: ["Type", "Access Pattern", "Max Size"] },
  { label: "Reliability", rows: ["Durability", "Availability"] },
  { label: "Cost", rows: ["Cost / GB-mo", "Cost / TB / Year", "Retrieval Fee"] },
  { label: "Performance", rows: ["Max IOPS", "Max Throughput", "Seq Write (MB/s) ¹", "Seq Read (MB/s) ¹", "Rand 4K Read IOPS ¹", "Rand 4K Write IOPS ¹", "Avg Latency (usec) ¹"] },
  { label: "Capabilities", rows: ["Multi-Instance", "POSIX Filesystem"] },
  { label: "Decision Guide", rows: ["Use When", "Don't Use When"] },
];

const colColors = ["#fff","#fafafa","#fff","#fafafa","#fff","#fafafa","#fff"];

const typeChip = (val) => {
  const map = {
    "Object": { bg: "#e8f0fe", fg: "#1a56db" },
    "Block":  { bg: "#fce8e6", fg: "#c5221f" },
    "File (NFS)":   { bg: "#e6f4ea", fg: "#137333" },
    "File (Lustre)": { bg: "#fef7e0", fg: "#b06000" },
  };
  return map[val] || null;
};

export default function App() {
  const [activeSection, setActiveSection] = useState(null);

  const visibleGroups = sectionGroups.filter(g => !activeSection || g.label === activeSection);

  return (
    <div style={{ fontFamily: "-apple-system, BlinkMacSystemFont, 'Inter', sans-serif", background: LIGHT, minHeight: "100vh", padding: "28px 20px" }}>

      {/* Header */}
      <div style={{ maxWidth: 1120, margin: "0 auto 22px" }}>
        <div style={{ fontSize: 10, fontWeight: 700, letterSpacing: "0.14em", textTransform: "uppercase", color: GRAY, marginBottom: 6 }}>
          Portfolio Artifact · Week 4 · AWS Cloud Engineer Program
        </div>
        <div style={{ fontSize: 26, fontWeight: 300, color: DARK, letterSpacing: "-0.5px", marginBottom: 4 }}>
          AWS Storage Decision Matrix
        </div>
        <div style={{ fontSize: 12, color: GRAY, marginBottom: 18 }}>
          Sebastiao Fresco · 2026
        </div>

        {/* Filter pills */}
        <div style={{ display: "flex", gap: 6, flexWrap: "wrap" }}>
          {sectionGroups.map(g => (
            <button key={g.label} onClick={() => setActiveSection(activeSection === g.label ? null : g.label)}
              style={{ fontSize: 11, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase", padding: "5px 14px", borderRadius: 980, border: "1px solid", borderColor: activeSection === g.label ? BLUE : "#d0d0d5", background: activeSection === g.label ? BLUE : "white", color: activeSection === g.label ? "white" : GRAY, cursor: "pointer", transition: "all 0.15s" }}>
              {g.label}
            </button>
          ))}
          {activeSection && (
            <button onClick={() => setActiveSection(null)}
              style={{ fontSize: 11, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase", padding: "5px 14px", borderRadius: 980, border: "1px solid #d0d0d5", background: "white", color: GRAY, cursor: "pointer" }}>
              Show All
            </button>
          )}
        </div>
      </div>

      {/* Table */}
      <div style={{ maxWidth: 1120, margin: "0 auto", overflowX: "auto" }}>
        <table style={{ width: "100%", borderCollapse: "collapse", background: "white", borderRadius: 12, overflow: "hidden", boxShadow: "0 2px 20px rgba(0,0,0,0.07)", userSelect: "none" }}>
          <thead>
            <tr>
              <th style={{ width: 175, padding: "13px 16px", textAlign: "left", fontSize: 10, fontWeight: 700, letterSpacing: "0.1em", textTransform: "uppercase", color: GRAY, background: "#fafafa", borderBottom: "2px solid #e0e0e5", position: "sticky", left: 0, zIndex: 2 }}>
                Criteria
              </th>
              {services.map((svc, i) => (
                <th key={svc} style={{ padding: "13px 10px", textAlign: "center", fontSize: 11, fontWeight: 700, color: DARK, background: colColors[i], borderBottom: "2px solid #e0e0e5", minWidth: 118, whiteSpace: "pre-line", lineHeight: 1.35 }}>
                  {svc}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {visibleGroups.map((group, gi) => (
              <>
                <tr key={`sec-${gi}`}>
                  <td colSpan={services.length + 1} style={{ padding: "9px 16px 5px", fontSize: 10, fontWeight: 700, letterSpacing: "0.12em", textTransform: "uppercase", color: BLUE, background: "#f5f8ff", borderTop: "2px solid #e8eaf6" }}>
                    {group.label}
                  </td>
                </tr>
                {group.rows.map((row, ri) => {
                  const rowData = matrix[row];
                  const winner = rowData?._winner;
                  return (
                    <tr key={row} style={{ background: ri % 2 === 0 ? "white" : "#fafafa" }}>
                      <td style={{ padding: "10px 16px", fontSize: 12, fontWeight: 600, color: GRAY, borderBottom: "1px solid #f0f0f2", position: "sticky", left: 0, background: ri % 2 === 0 ? "white" : "#fafafa", zIndex: 1, whiteSpace: "nowrap" }}>
                        {row}
                      </td>
                      {serviceKeys.map((svc, si) => {
                        const val = rowData[svc];
                        const chip = row === "Type" ? typeChip(val) : null;
                        const isWinner = winner === svc;
                        const isBenchmark = benchmarkRows.includes(row);
                        const isYes = val === "✅ Yes";
                        const isNo = val === "❌ No";
                        const isWarn = val?.startsWith("⚠️");

                        return (
                          <td key={svc} style={{ padding: "10px 10px", fontSize: 12, textAlign: "center", borderBottom: "1px solid #f0f0f2", background: isWinner && isBenchmark ? "#f0faf4" : (chip?.bg || colColors[si]), verticalAlign: "top", lineHeight: 1.5, position: "relative" }}>
                            {chip ? (
                              <span style={{ background: chip.bg, color: chip.fg, borderRadius: 4, padding: "2px 8px", fontSize: 11, fontWeight: 600 }}>{val}</span>
                            ) : isWinner && isBenchmark ? (
                              <span style={{ color: GREEN, fontWeight: 700 }}>{val} ✓</span>
                            ) : isYes ? (
                              <span style={{ color: GREEN, fontWeight: 600 }}>{val}</span>
                            ) : isNo ? (
                              <span style={{ color: RED, fontWeight: 600 }}>{val}</span>
                            ) : isWarn ? (
                              <span style={{ color: "#b06000", fontWeight: 500 }}>{val}</span>
                            ) : (
                              <span style={{ color: val === "N/A" || val === "—" ? "#b0b0b5" : DARK }}>{val}</span>
                            )}
                          </td>
                        );
                      })}
                    </tr>
                  );
                })}
              </>
            ))}
          </tbody>
        </table>
      </div>

      {/* Footnote */}
      <div style={{ maxWidth: 1120, margin: "16px auto 0", display: "flex", flexDirection: "column", gap: 8 }}>
        <div style={{ fontSize: 11, color: GRAY, lineHeight: 1.6, background: "white", borderRadius: 8, padding: "12px 16px", boxShadow: "0 1px 6px rgba(0,0,0,0.05)" }}>
          <span style={{ fontWeight: 700, color: DARK }}>¹ Lab benchmarks</span> — measured via <code style={{ fontSize: 11, background: "#f0f0f2", padding: "1px 5px", borderRadius: 3 }}>fio</code> on a <strong>t3.micro</strong> instance (us-east-1, January 2026). EFS outperformed gp3 on random IOPS and sequential read due to t3.micro network bandwidth constraints — on Nitro instances, EBS and EFS share the same network pipe, making the instance itself the bottleneck rather than the storage service. Results are not representative of dedicated or larger instance types.
        </div>
        <div style={{ display: "flex", gap: 16, flexWrap: "wrap", alignItems: "center" }}>
          {[["Object", "#e8f0fe", "#1a56db"], ["Block", "#fce8e6", "#c5221f"], ["File", "#e6f4ea", "#137333"]].map(([l, bg, fg]) => (
            <div key={l} style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 11, color: GRAY }}>
              <span style={{ width: 10, height: 10, borderRadius: 2, background: bg, border: `1px solid ${fg}`, display: "inline-block" }} />
              {l} storage
            </div>
          ))}
          <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 11, color: GRAY }}>
            <span style={{ color: GREEN, fontWeight: 700, fontSize: 12 }}>✓</span> Benchmark winner
          </div>
        </div>
      </div>
    </div>
  );
}
