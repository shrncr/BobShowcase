"""
Candidate Screening Tools for Brightwell TA Screening Assistant
This tool generates the standardized 5-part screening summary.
"""
from ibm_watsonx_orchestrate.agent_builder.tools import tool
from typing import Dict, Optional, Any

# Embedded data copies - tools must be self-contained
REQUISITION_DATA = [
    {
        "req_id": "REQ-2026-001",
        "title": "Registered Nurse - ICU",
        "must_haves": {
            "license": "Active RN license in state",
            "years_experience": "2+ years ICU experience",
            "unit_experience": "ICU or Critical Care",
            "certifications": "BLS, ACLS"
        },
        "nice_to_haves": {
            "additional_certs": "CCRN certification",
            "specialty": "Trauma or cardiac ICU experience",
            "education": "BSN preferred"
        }
    },
    {
        "req_id": "REQ-2026-002",
        "title": "Medical Assistant - Primary Care",
        "must_haves": {
            "certification": "Certified Medical Assistant (CMA) or Registered Medical Assistant (RMA)",
            "years_experience": "1+ years in primary care or family medicine",
            "skills": "Vital signs, EHR documentation, patient intake"
        },
        "nice_to_haves": {
            "ehr_systems": "Epic or Cerner experience",
            "languages": "Bilingual (English/Spanish)",
            "specialty": "Pediatrics or geriatrics experience"
        }
    },
    {
        "req_id": "REQ-2026-003",
        "title": "Physical Therapist",
        "must_haves": {
            "license": "Active PT license in state",
            "degree": "Doctor of Physical Therapy (DPT)",
            "years_experience": "1+ years clinical experience"
        },
        "nice_to_haves": {
            "specialty": "Orthopedic or sports medicine",
            "certifications": "Board certification in specialty area",
            "experience": "Outpatient clinic experience"
        }
    },
    {
        "req_id": "REQ-2026-004",
        "title": "Clinical Lab Technician",
        "must_haves": {
            "certification": "MLT or MLS certification",
            "license": "State clinical lab license",
            "years_experience": "2+ years in clinical laboratory",
            "skills": "Hematology, chemistry, microbiology"
        },
        "nice_to_haves": {
            "specialty": "Blood bank or molecular diagnostics",
            "systems": "LIS experience (Cerner or Epic)",
            "shift": "Willingness to work nights/weekends"
        }
    },
    {
        "req_id": "REQ-2026-005",
        "title": "Nurse Practitioner - Family Medicine",
        "must_haves": {
            "license": "Active NP license with prescriptive authority",
            "certification": "FNP-C or AGPCNP-C certification",
            "years_experience": "2+ years as practicing NP",
            "specialty": "Family medicine or primary care"
        },
        "nice_to_haves": {
            "population": "Pediatric and geriatric experience",
            "procedures": "Minor procedures (suturing, joint injections)",
            "languages": "Bilingual preferred"
        }
    }
]

CANDIDATE_DATA = [
    {
        "candidate_id": "CAND-001",
        "name": "Jennifer Martinez",
        "applied_for": "REQ-2026-001",
        "license_info": "RN License #RN123456, California, Active through 2027",
        "years_experience": "4 years",
        "unit_experience": "ICU - 3 years at County General Hospital, 1 year CVICU at Regional Medical",
        "certifications": "BLS, ACLS, CCRN",
        "education": "BSN, University of California",
        "resume_summary": "Experienced ICU nurse with strong critical care background. Specialized in cardiac and trauma ICU."
    },
    {
        "candidate_id": "CAND-002",
        "name": "Michael Chen",
        "applied_for": "REQ-2026-001",
        "license_info": "RN License #RN789012, California, Active through 2026",
        "years_experience": "1.5 years",
        "unit_experience": "Med-Surg - 1.5 years at Community Hospital",
        "certifications": "BLS, ACLS",
        "education": "ADN, City College",
        "resume_summary": "Recent nursing graduate with med-surg experience. Completed ICU clinical rotation during nursing school."
    },
    {
        "candidate_id": "CAND-003",
        "name": "Sarah Johnson",
        "applied_for": "REQ-2026-002",
        "license_info": "CMA Certification #CMA456789, Active through 2027",
        "years_experience": "3 years",
        "unit_experience": "Primary Care - 2 years at Family Health Clinic, 1 year at Pediatric Associates",
        "certifications": "CMA, BLS",
        "resume_summary": "Certified Medical Assistant with extensive primary care experience. Proficient in Epic EHR. Bilingual English/Spanish."
    },
    {
        "candidate_id": "CAND-004",
        "name": "David Thompson",
        "applied_for": "REQ-2026-003",
        "license_info": "PT License #PT234567, California, Active through 2028",
        "years_experience": "5 years",
        "unit_experience": "Outpatient orthopedics - 3 years, Sports medicine clinic - 2 years",
        "certifications": "DPT, OCS (Orthopedic Clinical Specialist)",
        "resume_summary": "Board-certified orthopedic physical therapist with extensive outpatient experience. Specialized in sports injuries."
    },
    {
        "candidate_id": "CAND-005",
        "name": "Lisa Patel",
        "applied_for": "REQ-2026-004",
        "license_info": "MLS Certification #MLS345678, California Clinical Lab License #CLS987654, Active",
        "years_experience": "6 years",
        "unit_experience": "Clinical laboratory - 4 years at University Hospital, 2 years at Reference Lab",
        "certifications": "MLS (ASCP), Blood Bank Specialist",
        "resume_summary": "Experienced medical laboratory scientist with expertise across all departments. Specialized in blood bank."
    },
    {
        "candidate_id": "CAND-006",
        "name": "Robert Williams",
        "applied_for": "REQ-2026-005",
        "license_info": "NP License #NP567890, California, Active with prescriptive authority through 2027",
        "years_experience": "8 years",
        "unit_experience": "Family medicine - 5 years as NP at Community Health Center, 3 years as RN in primary care",
        "certifications": "FNP-C, BLS, ACLS",
        "resume_summary": "Board-certified Family Nurse Practitioner with extensive primary care experience. Bilingual English/Spanish."
    },
    {
        "candidate_id": "CAND-007",
        "name": "Amanda Foster",
        "applied_for": "REQ-2026-001",
        "license_info": "License information not provided in application",
        "years_experience": "2 years",
        "unit_experience": "Emergency Department - 2 years at Metro Hospital",
        "certifications": "BLS, ACLS, TNCC",
        "resume_summary": "Emergency department nurse with strong critical care skills. Interested in transitioning to ICU."
    }
]

@tool
def screen_candidate_against_req(
    candidate_id: str,
    req_id: str
) -> Dict[str, Any]:
    """Screen a candidate against a requisition and generate standardized 5-part summary.
    
    This is the core screening tool that produces the consistent format Brightwell Health requires:
    1. Match Call (Strong/Possible/No)
    2. Must-Haves Checklist
    3. Relevant Experience Summary
    4. Flags for missing/unclear information
    5. Recommended Next Step
    
    Args:
        candidate_id: The candidate ID (e.g., CAND-001)
        req_id: The requisition ID (e.g., REQ-2026-001)
    """
    # Find candidate
    candidate = None
    for c in CANDIDATE_DATA:
        if c.get("candidate_id") == candidate_id:
            candidate = c
            break
    
    if not candidate:
        return {
            "success": False,
            "error": f"Candidate {candidate_id} not found"
        }
    
    # Find requisition
    requisition = None
    for r in REQUISITION_DATA:
        if r.get("req_id") == req_id:
            requisition = r
            break
    
    if not requisition:
        return {
            "success": False,
            "error": f"Requisition {req_id} not found"
        }
    
    # Generate 5-part screening summary
    must_haves = requisition.get("must_haves", {})
    nice_to_haves = requisition.get("nice_to_haves", {})
    
    # Evaluate must-haves
    must_have_results = {}
    flags = []
    must_haves_met = 0
    must_haves_total = len(must_haves)
    
    # Check license
    if "license" in must_haves:
        license_info = candidate.get("license_info", "")
        if "not provided" in license_info.lower() or not license_info:
            must_have_results["License"] = "✗ No - Not provided"
            flags.append("License information missing from application")
        elif "license" in license_info.lower() and "active" in license_info.lower():
            must_have_results["License"] = f"✓ Yes - {license_info[:60]}"
            must_haves_met += 1
        else:
            must_have_results["License"] = f"? Unclear - {license_info[:60]}"
            flags.append("License status unclear")
    
    # Check certification
    if "certification" in must_haves:
        cert_info = candidate.get("certifications", "") or candidate.get("license_info", "")
        required = must_haves["certification"]
        if any(cert in cert_info.upper() for cert in ["CMA", "RMA", "MLT", "MLS", "FNP-C", "AGPCNP-C"]):
            must_have_results["Certification"] = f"✓ Yes - {cert_info[:60]}"
            must_haves_met += 1
        else:
            must_have_results["Certification"] = f"✗ No - {cert_info[:60] if cert_info else 'Not provided'}"
    
    # Check years of experience
    if "years_experience" in must_haves:
        years_text = candidate.get("years_experience", "")
        required_years = must_haves["years_experience"]
        try:
            candidate_years = float(years_text.split()[0])
            required_num = float(required_years.split("+")[0])
            if candidate_years >= required_num:
                must_have_results["Years Experience"] = f"✓ Yes - {years_text}"
                must_haves_met += 1
            else:
                must_have_results["Years Experience"] = f"✗ No - {years_text} (requires {required_years})"
        except:
            must_have_results["Years Experience"] = f"? Unclear - {years_text}"
            flags.append("Years of experience unclear")
    
    # Check unit/specialty experience
    if "unit_experience" in must_haves or "specialty" in must_haves:
        unit_text = candidate.get("unit_experience", "")
        required = must_haves.get("unit_experience") or must_haves.get("specialty", "")
        keywords = ["icu", "critical care", "primary care", "family medicine", "orthopedic", "sports", "laboratory", "lab"]
        if any(kw in unit_text.lower() for kw in keywords):
            must_have_results["Unit/Specialty Experience"] = f"✓ Yes - {unit_text[:60]}"
            must_haves_met += 1
        else:
            must_have_results["Unit/Specialty Experience"] = f"✗ No - {unit_text[:60]}"
    
    # Check certifications (BLS, ACLS, etc.)
    if "certifications" in must_haves:
        cert_text = candidate.get("certifications", "")
        required_certs = must_haves["certifications"].replace(" ", "").split(",")
        has_all = all(cert.upper() in cert_text.upper() for cert in required_certs)
        if has_all:
            must_have_results["Required Certifications"] = f"✓ Yes - {cert_text}"
            must_haves_met += 1
        else:
            missing = [cert for cert in required_certs if cert.upper() not in cert_text.upper()]
            must_have_results["Required Certifications"] = f"✗ No - Missing: {', '.join(missing)}"
    
    # Check skills
    if "skills" in must_haves:
        must_have_results["Required Skills"] = "✓ Yes - Assumed from experience"
        must_haves_met += 1
    
    # Check degree
    if "degree" in must_haves:
        education = candidate.get("education", "")
        required_degree = must_haves["degree"]
        if any(deg in education.upper() for deg in ["DPT", "BSN", "MSN", "BS", "MS"]):
            must_have_results["Degree"] = f"✓ Yes - {education}"
            must_haves_met += 1
        else:
            must_have_results["Degree"] = f"? Unclear - {education}"
    
    # Evaluate nice-to-haves
    nice_to_have_results = {}
    for requirement, description in nice_to_haves.items():
        if requirement == "additional_certs":
            cert_text = candidate.get("certifications", "")
            if "CCRN" in cert_text.upper():
                nice_to_have_results["CCRN Certification"] = "✓ Yes"
            else:
                nice_to_have_results["CCRN Certification"] = "✗ No"
        elif requirement == "education":
            education = candidate.get("education", "")
            if "BSN" in education.upper():
                nice_to_have_results["BSN Degree"] = "✓ Yes"
            else:
                nice_to_have_results["BSN Degree"] = "✗ No"
        elif requirement == "languages":
            resume = candidate.get("resume_summary", "")
            if "bilingual" in resume.lower() or "spanish" in resume.lower():
                nice_to_have_results["Bilingual"] = "✓ Yes"
            else:
                nice_to_have_results["Bilingual"] = "✗ No"
        elif requirement == "ehr_systems":
            resume = candidate.get("resume_summary", "")
            if "epic" in resume.lower() or "cerner" in resume.lower():
                nice_to_have_results["EHR Experience"] = "✓ Yes"
            else:
                nice_to_have_results["EHR Experience"] = "✗ No"
    
    # Determine match call
    match_percentage = (must_haves_met / must_haves_total * 100) if must_haves_total > 0 else 0
    if match_percentage >= 80:
        match_call = "Strong"
    elif match_percentage >= 50:
        match_call = "Possible"
    else:
        match_call = "No"
    
    # Determine recommendation
    if match_call == "Strong":
        recommendation = "Phone Screen - Strong match on must-haves"
    elif match_call == "Possible":
        recommendation = "Phone Screen - Meets some requirements, worth exploring"
    else:
        recommendation = "Pass - Does not meet minimum requirements"
    
    # Build the 5-part summary
    summary = {
        "success": True,
        "candidate_id": candidate_id,
        "candidate_name": candidate.get("name"),
        "req_id": req_id,
        "req_title": requisition.get("title"),
        
        # Part 1: Match Call
        "match_call": match_call,
        "match_percentage": f"{match_percentage:.0f}%",
        
        # Part 2: Must-Haves Checklist
        "must_haves_checklist": must_have_results,
        "must_haves_met": f"{must_haves_met}/{must_haves_total}",
        
        # Part 3: Relevant Experience Summary
        "experience_summary": candidate.get("resume_summary", ""),
        
        # Part 4: Flags
        "flags": flags if flags else ["None"],
        
        # Part 5: Recommended Next Step
        "recommendation": recommendation,
        
        # Additional context
        "nice_to_haves": nice_to_have_results
    }
    
    return summary

# Made with Bob
