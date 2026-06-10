"""
Candidate Management Tools for Brightwell TA Screening Assistant
"""
from ibm_watsonx_orchestrate.agent_builder.tools import tool
from typing import Dict, List, Optional, Any

# Embedded candidate data - WXO tools cannot access local files
CANDIDATE_DATA = [
    {
        "candidate_id": "CAND-001",
        "name": "Jennifer Martinez",
        "email": "j.martinez@email.com",
        "phone": "555-0101",
        "status": "screening_pending",
        "applied_for": "REQ-2026-001",
        "license_info": "RN License #RN123456, California, Active through 2027",
        "years_experience": "4 years",
        "unit_experience": "ICU - 3 years at County General Hospital, 1 year CVICU at Regional Medical",
        "certifications": "BLS, ACLS, CCRN",
        "education": "BSN, University of California",
        "resume_summary": "Experienced ICU nurse with strong critical care background. Specialized in cardiac and trauma ICU. Proven track record managing complex patients on ventilators, CRRT, and ECMO. Excellent collaboration with interdisciplinary teams."
    },
    {
        "candidate_id": "CAND-002",
        "name": "Michael Chen",
        "email": "m.chen@email.com",
        "phone": "555-0102",
        "status": "screening_pending",
        "applied_for": "REQ-2026-001",
        "license_info": "RN License #RN789012, California, Active through 2026",
        "years_experience": "1.5 years",
        "unit_experience": "Med-Surg - 1.5 years at Community Hospital",
        "certifications": "BLS, ACLS",
        "education": "ADN, City College",
        "resume_summary": "Recent nursing graduate with med-surg experience. Strong clinical skills and eager to transition to critical care. Completed ICU clinical rotation during nursing school. Quick learner with excellent patient assessment skills."
    },
    {
        "candidate_id": "CAND-003",
        "name": "Sarah Johnson",
        "email": "s.johnson@email.com",
        "phone": "555-0103",
        "status": "screening_pending",
        "applied_for": "REQ-2026-002",
        "license_info": "CMA Certification #CMA456789, Active through 2027",
        "years_experience": "3 years",
        "unit_experience": "Primary Care - 2 years at Family Health Clinic, 1 year at Pediatric Associates",
        "certifications": "CMA, BLS",
        "education": "Medical Assistant Diploma, Technical Institute",
        "resume_summary": "Certified Medical Assistant with extensive primary care experience. Proficient in Epic EHR, patient intake, vital signs, and clinical documentation. Bilingual English/Spanish. Strong patient communication skills and ability to work in fast-paced environment."
    },
    {
        "candidate_id": "CAND-004",
        "name": "David Thompson",
        "email": "d.thompson@email.com",
        "phone": "555-0104",
        "status": "screening_pending",
        "applied_for": "REQ-2026-003",
        "license_info": "PT License #PT234567, California, Active through 2028",
        "years_experience": "5 years",
        "unit_experience": "Outpatient orthopedics - 3 years, Sports medicine clinic - 2 years",
        "certifications": "DPT, OCS (Orthopedic Clinical Specialist)",
        "education": "Doctor of Physical Therapy, State University",
        "resume_summary": "Board-certified orthopedic physical therapist with extensive outpatient experience. Specialized in sports injuries, post-surgical rehabilitation, and manual therapy. Strong outcomes with return-to-sport protocols. Excellent patient education and home exercise program development."
    },
    {
        "candidate_id": "CAND-005",
        "name": "Lisa Patel",
        "email": "l.patel@email.com",
        "phone": "555-0105",
        "status": "screening_pending",
        "applied_for": "REQ-2026-004",
        "license_info": "MLS Certification #MLS345678, California Clinical Lab License #CLS987654, Active",
        "years_experience": "6 years",
        "unit_experience": "Clinical laboratory - 4 years at University Hospital, 2 years at Reference Lab",
        "certifications": "MLS (ASCP), Blood Bank Specialist",
        "education": "BS in Medical Laboratory Science, State University",
        "resume_summary": "Experienced medical laboratory scientist with expertise across all departments. Specialized in blood bank and transfusion services. Proficient in Cerner LIS. Strong quality control and regulatory compliance knowledge. Available for rotating shifts including nights and weekends."
    },
    {
        "candidate_id": "CAND-006",
        "name": "Robert Williams",
        "email": "r.williams@email.com",
        "phone": "555-0106",
        "status": "screening_pending",
        "applied_for": "REQ-2026-005",
        "license_info": "NP License #NP567890, California, Active with prescriptive authority through 2027",
        "years_experience": "8 years",
        "unit_experience": "Family medicine - 5 years as NP at Community Health Center, 3 years as RN in primary care",
        "certifications": "FNP-C, BLS, ACLS",
        "education": "MSN Family Nurse Practitioner, University of California",
        "resume_summary": "Board-certified Family Nurse Practitioner with extensive primary care experience across lifespan. Proficient in chronic disease management, preventive care, and minor procedures. Experience with underserved populations. Strong diagnostic and clinical decision-making skills. Bilingual English/Spanish."
    },
    {
        "candidate_id": "CAND-007",
        "name": "Amanda Foster",
        "email": "a.foster@email.com",
        "phone": "555-0107",
        "status": "screening_pending",
        "applied_for": "REQ-2026-001",
        "license_info": "License information not provided in application",
        "years_experience": "2 years",
        "unit_experience": "Emergency Department - 2 years at Metro Hospital",
        "certifications": "BLS, ACLS, TNCC",
        "education": "BSN, State University",
        "resume_summary": "Emergency department nurse with strong critical care skills. Experience managing high-acuity patients, trauma, and rapid response situations. Excellent under pressure. Interested in transitioning to ICU for more focused critical care experience."
    }
]

@tool
def get_candidate_data(
    candidate_id: Optional[str] = None,
    applied_for: Optional[str] = None,
    status: Optional[str] = None,
    limit: Optional[int] = None
) -> Dict[str, Any]:
    """Retrieve candidate data with flexible filtering options.
    
    Args:
        candidate_id: Filter by specific candidate ID
        applied_for: Filter by requisition ID they applied for
        status: Filter by application status
        limit: Maximum number of results to return
    """
    results = CANDIDATE_DATA.copy()
    
    if candidate_id:
        results = [c for c in results if c.get("candidate_id") == candidate_id]
    if applied_for:
        results = [c for c in results if c.get("applied_for") == applied_for]
    if status:
        results = [c for c in results if c.get("status") == status]
    if limit and limit > 0:
        results = results[:limit]
    
    return {
        "count": len(results),
        "candidates": results
    }

@tool
def get_candidate_by_id(candidate_id: str) -> Dict[str, Any]:
    """Retrieve a single candidate by their unique identifier.
    
    Args:
        candidate_id: The candidate ID (e.g., CAND-001)
    """
    for candidate in CANDIDATE_DATA:
        if candidate.get("candidate_id") == candidate_id:
            return {
                "found": True,
                "candidate": candidate
            }
    return {
        "found": False,
        "error": f"Candidate {candidate_id} not found"
    }

# Made with Bob
