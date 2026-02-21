import streamlit as st
import pandas as pd
import pyodbc
from streamlit_lottie import st_lottie
import requests

# --- CONFIGURATION ---
st.set_page_config(page_title="University Management System", layout="wide")


# --- CUSTOM CSS & ANIMATIONS ---
def local_css():
    st.markdown("""
    <style>
        /* Main container styling */
        .main {
            background-color: #f0f2f6;
        }
        /* Custom Card styling */
        .st-emotion-cache-12w0qpk { 
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);bv
            padding: 2rem;
        }
        /* Button Animations */
        div.stButton > button:first-child {
            background-color: #4F46E5;
            color: white;
            border-radius: 8px;
            transition: all 0.3s ease;
            width: 100%;
        }
        div.stButton > button:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(79, 70, 229, 0.4);
        }
        /* Glassmorphism Sidebar */
        [data-testid="stSidebar"] {
            background-image: linear-gradient(180deg, #2e3b4e 0%, #1a1c23 100%);
            color: white;
        }
    </style>
    """, unsafe_allow_html=True)


def load_lottieurl(url: str):
    r = requests.get(url)
    if r.status_code != 200:
        return None
    return r.json()


# --- DATABASE CONNECTION ---
def connect_db(user, pwd):
    # Update driver/server as per your environment
    conn_str = (
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER=localhost\SQLEXPRESS;"
        f"DATABASE=University;"
        f"UID={user};PWD={pwd}"
    )
    return pyodbc.connect(conn_str)


# --- APP LOGIC ---
local_css()
lottie_user = load_lottieurl("https://assets5.lottiefiles.com/packages/lf20_s7pm8v7s.json")

if "logged_in" not in st.session_state:
    st.session_state.logged_in = False

# --- LOGIN INTERFACE ---
if not st.session_state.logged_in:
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        if lottie_user:
            st_lottie(lottie_user, height=200)
        st.markdown("<h1 style='text-align: center;'>University Portal</h1>", unsafe_allow_html=True)

        with st.container(border=True):
            username = st.text_input("Username", placeholder="e.g., admin1")
            password = st.text_input("Password", type="password")

            if st.button("Authenticate"):
                try:
                    # In production, use a secure method to map input to SQL logins
                    st.session_state.conn = connect_db(username, password)
                    st.session_state.username = username
                    st.session_state.logged_in = True
                    st.rerun()
                except Exception as e:
                    st.error("Access Denied: Verify credentials.")

# --- MAIN DASHBOARD ---
else:
    # Sidebar Navigation
    with st.sidebar:
        st.image("https://cdn-icons-png.flaticon.com/512/3135/3135715.png", width=100)
        st.write(f"Logged in as: **{st.session_state.username}**")
        st.divider()
        menu = st.radio("Navigation", ["Dashboard", "Students", "Academic Actions", "Reports"])

        if st.button("Logout", width= "stretch"):
            st.session_state.logged_in = False
            st.rerun()

    # --- DASHBOARD VIEW ---
    if menu == "Dashboard":
        st.title("Welcome to the University Management System")
        metrics_col1, metrics_col2, metrics_col3 = st.columns(3)
        metrics_col1.metric("Status", "Online", "Server Active")
        metrics_col2.metric("User Role", st.session_state.username.upper())

    # --- STUDENTS VIEW ---
    elif menu == "Students":
        st.subheader("📋 Student Records Explorer")
        try:
            query = "SELECT * FROM StudentsFCM_41_023_025_24"
            df = pd.read_sql(query, st.session_state.conn)

            # Search Bar for interactivity
            search = st.text_input("Filter by Name")
            if search:
                df = df[df['full_name'].str.contains(search, case=False)]

            st.dataframe(df, width= "content", hide_index=True)
        except Exception as e:
            st.error("You do not have permission to view this table.")

    # --- ACADEMIC ACTIONS (REGISTRATION & GRADES) ---
    elif menu == "Academic Actions":
        tab1, tab2 = st.tabs(["Student Registration", "Grade Entry"])

        with tab1:
            if st.session_state.username == "admin1":
                st.markdown("### Register New Student")
                with st.form("reg_form", clear_on_submit=True):
                    c1, c2 = st.columns(2)
                    name = c1.text_input("Full Name")
                    email = c2.text_input("Email Address")
                    prog = c1.selectbox("Program", ["Computer Science", "IT", "CyberSecurity", "Data Science"])
                    year = c2.slider("Year of Study", 1, 4)

                    if st.form_submit_button("Submit Registration"):
                        cursor = st.session_state.conn.cursor()
                        cursor.execute("EXEC register_student ?, ?, ?, ?", (name, email, prog, year))
                        st.session_state.conn.commit()
                        st.balloons()
                        st.success(f"Successfully registered {name}!")
            else:
                st.warning("Admin privileges required for registration.")

        with tab2:
            if st.session_state.username in ["admin1", "staff1"]:
                st.markdown("### Update Student Grades")
                with st.container(border=True):
                    e_id = st.number_input("Enrollment ID", min_value=1)
                    score = st.number_input("Final Score", 0.0, 100.0)

                    if st.button("Post Grade"):
                        try:
                            cursor = st.session_state.conn.cursor()
                            cursor.execute("INSERT INTO GradesFCM_41_023_025_24 (enrollment_id, score) VALUES (?, ?)",
                                           (e_id, score))
                            st.session_state.conn.commit()
                            st.success("Grade posted successfully.")
                        except Exception as e:
                            st.error(f"Error: {e}")
            else:
                st.warning("Staff or Admin privileges required.")

    # --- REPORTS ---
    elif menu == "Reports":
        st.subheader("🎓 Graduation & Performance Analysis")
        sid = st.number_input("Enter Student ID to check Eligibility", min_value=1)

        if st.button("Check Eligibility"):
            cursor = st.session_state.conn.cursor()
            # Fetch CWA
            cwa_res = cursor.execute("SELECT dbo.calculate_cwa(?)", (sid,)).fetchone()

            if cwa_res and cwa_res[0] is not None:
                cwa_val = float(cwa_res[0])
                st.metric("Current CWA", f"{cwa_val:.2f}")

                if cwa_val >= 2.0:
                    st.success("✅ Eligible for Graduation")
                else:
                    st.error("❌ Not Eligible for Graduation")
            else:
                st.info("No grade data found for this student.")